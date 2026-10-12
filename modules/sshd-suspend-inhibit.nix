# sshd-suspend-inhibit.nix
# Prevents the system from suspending while an SSH session is active.
# Original by `cbrauchli`: https://discourse.nixos.org/t/disable-suspend-if-ssh-sessions-are-active/11655/4
# With minor modifications by Dominic Mayhew.
{ pkgs, ... }:

let
  PID_PATH = "/tmp/ssh_sleep_block.pid";
  PID_PIPE = "pid_pipe";

  sleep_script = pkgs.writeScript "infinite-sleep" ''
    #!/bin/sh
    echo $$ >${PID_PATH}
    echo $$ >${PID_PIPE}
    sleep infinity
  '';

  inhibit_script = pkgs.writeScript "inhibit_script" ''
    #!/bin/sh
    systemd-inhibit --what=sleep --why="Active SSH session" --mode=block ${sleep_script} 0<&- >/tmp/inhibit.out &
  '';

  ssh_script = pkgs.writeScript "ssh-session-handler" ''
    #!/bin/sh
    # Masks/unmasks systemd sleep+hibernate targets on SSH open/close.
    # Inspired by: https://unix.stackexchange.com/a/136552/84197
    #              https://askubuntu.com/a/954943/388360

    num_ssh=$(netstat -nt | awk '$4 ~ /:22$/ && $6 == "ESTABLISHED"' | wc -l)

    case "$PAM_TYPE" in
      open_session)
        [ "$num_ssh" -gt 1 ] && exit
        logger "Starting sleep inhibitor"
        mkfifo ${PID_PIPE}
        ${inhibit_script}
        logger "Sleep inhibitor started with PID $(cat ${PID_PIPE})"
        rm ${PID_PIPE}
        ;;

      close_session)
        [ "$num_ssh" -ne 0 ] && exit
        logger "Killing sleep inhibitor PID $(cat ${PID_PATH})"
        kill -9 "$(cat ${PID_PATH})" && rm ${PID_PATH}
        ;;

      *) exit ;;
    esac
  '';
in
{
  security.pam.services.sshd.text = pkgs.lib.mkDefault (
    pkgs.lib.mkAfter
      "# Prevent sleep on active SSH\nsession optional pam_exec.so quiet ${ssh_script}"
  );
}
