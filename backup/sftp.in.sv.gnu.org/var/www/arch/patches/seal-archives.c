/*
 *    Seal Arch Archives
 *    Copyright (C) 2005  Michael J. Flickinger <mjflick@gnu.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, write to the Free Software
 *   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/


#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <time.h>
#include <regex.h>

#define LOG_FILE "/var/log/seal_log.txt"
#define ARCHIVE_PATH "/archives/|/var/lib/arch/"   // path, (regex)

int
regex_match (char *pat, const char* string)
{
  int    result;
  regex_t    re;

  if (regcomp(&re, pat, REG_EXTENDED|REG_NOSUB) != 0)
    return(-1);

  result = regexec(&re, string, (size_t) 0, NULL, 0);
  regfree(&re);
  if (result != 0)
    return(0);

  return(1);
}


int
main (int argc, char **argv)
{
  uid_t orig_uid;
  orig_uid = getuid();

  setuid(0);

  if (argc < 2)
    return 0;

  if (regex_match(ARCHIVE_PATH, argv[1]))
    if (regex_match("\\.gz$|checksum$|log$", argv[1]))
    {
      time_t t1;
      (void) time(&t1);
      char s_time[24];

      chmod(argv[1], 0444);
      chown(argv[1], 0, 0);

      strcpy(s_time, ctime(&t1));
      s_time[24] = 0;

      int fd = open(LOG_FILE, O_WRONLY | O_APPEND | O_CREAT);
      FILE *log = fdopen(fd, "a");

      char f_message[ 26 + strlen(argv[1]) + 200];

      sprintf(f_message, "[%s] - \"%s\" sealed\n", s_time, argv[1]);

      flock(fd, LOCK_EX);
      fwrite(f_message, strlen(f_message), 1, log);
      flock(fd, LOCK_UN);
      
      fclose(log);
      close(fd);
    }
  setuid(orig_uid);

  return 0;
}
