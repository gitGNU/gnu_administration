# ~/.profile: executed by Bourne-compatible login shells.

# When interactive, start zsh for those who prefer it.
if test -n "$PS1" -a -x /bin/zsh; then
  case ${SSH_CLIENT%% *} in
    82.230.74.64|78.114.223.227)
      export HOME=/root/Meyering
      cd $HOME && exec /bin/zsh;;
  esac
fi

if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11
export PATH

mesg n

echo "Please remember to update /root/ChangeLog when you modify a configuration file."
echo "Tip:  Use  \`C-x 4 a'  in emacs to add a new entry."

# Expose first few lines of ChangeLog (ie. most recent activity)
echo -e "\n--"; head -n15 ~/ChangeLog; echo -e "--\n"
echo "Check infra/*.txt for documentation :)"
