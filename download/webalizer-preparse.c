/*
 * Split Apache logs exactly per month, for webalizer to import

 * Copyright (C) 2009  Sylvain Beucler

 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 3 of the
 * License, or (at your option) any later version.

 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

/* In non-incremental mode, Webalizer resets the current month at each
   new log file. In this case, it's necessary to preprocess the log
   before the import and split them per month. This is also necessary
   if you're switching from non-Incremental mode to Incremental mode -
   but you probably should use Incremental mode from the start. */

/*
Usage:

name=audio-video
mkdir t || rm -rf t/*
gcc -O2 webalizer-preparse.c && time for i in `ls -rt /var/log/apache2/$name/access.log*`; do echo $i >&2; zcat -f $i; done | ./a.out

rm -f /var/www/$name/webalizer/*; for i in t/*; do echo; echo $i; webalizer -c /etc/webalizer/$name.conf $i; done

*/

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>

char buf[BUFSIZ];
char *pc = buf + BUFSIZ;
int cur_siz = BUFSIZ;
char *start = buf;
FILE* fds[3000][12];

FILE* fopenz(int year, int month)
{
  /* http://www.gnu.org/software/libtool/manual/libc/Creating-a-Pipe.html */
  pid_t pid;
  int mypipe[2];

  /* Create the pipe. */
  if (pipe(mypipe) < 0) { perror("pipe"); return NULL; }
  
  /* Create the child process. */
  pid = fork ();
  if (pid == (pid_t) 0)
    {
      /* This is the child process.
	 Close other end first. */
      close (mypipe[1]);
      /* mypipe[0] is for reading */

      /* redirect standard input */
      if (dup2(mypipe[0], STDIN_FILENO) < 0) { fprintf(stderr, "mypipe[0]=%d, STDIN_FILENO=%d - ", mypipe[0], STDIN_FILENO); perror("dup2"); exit(1); }

      /* redirect standard output */
      char filename[17] = "t/200X-XX.log.gz";
      sprintf(filename, "t/%d-%02d.log.gz", year, month+1);
      FILE *fout = fopen(filename, "w");
      int out = fileno(fout);
      if (dup2(out, STDOUT_FILENO) < 0) { fprintf(stderr, "out=%d, STDOUT_FILENO=%d - ", out, STDOUT_FILENO); perror("dup2"); exit(2); }

      /* Start gzip */
      execlp("gzip", "gzip", NULL);

      fprintf(stderr, "exec failed\n");
      exit(0);
    }
  else if (pid < (pid_t) 0)
    {
      /* The fork failed. */
      fprintf (stderr, "Fork failed.\n");
      return NULL;
    }
  else
    {
      /* This is the parent process.
	 Close other end first. */
      close (mypipe[0]);
      /* mypipe[1] is for writing */
      return fdopen(mypipe[1], "w"); /* for writing  */
    }
}

int main(void)
{
  char last_month[4];
  char cur_month[4];
  char cur_year[5];
  last_month[0] = '\0';
  cur_month[3] = '\0';
  cur_year[4] = '\0';
  memset(fds, 0, sizeof(fds));
  while (fgets(buf, BUFSIZ, stdin) != NULL)
    {
      char* pc;
      if (strchr(buf, '\n') == NULL)
	{
	  fprintf(stderr, "Skipping line too long: %s\n", buf);
	  continue;
	}
      if ((pc = strchr(buf, '/')) == NULL)
	{
	  fprintf(stderr, "Skipping bad line: %s\n", buf);
	  continue;
	}
      strncpy(cur_month, pc+1, 3);
      strncpy(cur_year, pc+5, 4);
/*       if (strcmp(cur_month, last_month) != 0) */
/* 	{ */
/* 	  printf("changing month: %s %s\n", cur_month, cur_year); */
/* 	  strcpy(last_month, cur_month); */
/* 	} */
      int year = atoi(cur_year);
      if (year < 1990 || year > 2100)
	{
	  printf("Error: bad year %s\n", cur_year);
	  continue;
	}

      int month = -1;
      switch(cur_month[0])
	{
	case 'J':
	  if (cur_month[1] == 'a')
	    month = 0;
	  else if (cur_month[2] == 'n')
	    month = 5;
	  else if (cur_month[2] == 'l')
	    month = 6;
	  break;
	case 'F':
	  month = 1;
	  break;
	case 'M':
	  if (cur_month[2] == 'r')
	    month = 2;
	  else if (cur_month[2] == 'y')
	    month = 4;
	  break;
	case 'A':
	  if (cur_month[1] == 'p')
	    month = 3;
	  else if (cur_month[1] == 'u')
	    month = 7;
	  break;
	case 'S':
	  month = 8;
	  break;
	case 'O':
	  month = 9;
	  break;
	case 'N':
	  month = 10;
	  break;
	case 'D':
	  month = 11;
	  break;
	}
      if (month == -1)
	{
	  printf("Error: bad month %s\n", cur_month);
	  continue;
	}

/*       if (strcmp(cur_month, "Jan")) */
/* 	month = 0; */
/*       else if (strcmp(cur_month, "Fev")) */
/* 	month = 1; */
/*       else if (strcmp(cur_month, "Mar")) */
/* 	month = 2; */
/*       else if (strcmp(cur_month, "Apr")) */
/* 	month = 3; */
/*       else if (strcmp(cur_month, "May")) */
/* 	month = 4; */
/*       else if (strcmp(cur_month, "Jun")) */
/* 	month = 5; */
/*       else if (strcmp(cur_month, "Jul")) */
/* 	month = 6; */
/*       else if (strcmp(cur_month, "Aug")) */
/* 	month = 7; */
/*       else if (strcmp(cur_month, "Sep")) */
/* 	month = 8; */
/*       else if (strcmp(cur_month, "Oct")) */
/* 	month = 9; */
/*       else if (strcmp(cur_month, "Nov")) */
/* 	month = 10; */
/*       else if (strcmp(cur_month, "Dev")) */
/* 	month = 11; */

      if (fds[year][month] == NULL)
	{
	  fds[year][month] = fopenz(year, month);
	  if (fds[year][month] == NULL)
	    exit(1);
	}
      fputs(buf, fds[year][month]);
    }

  int i = 0;
  for (i = 0; i < 3000; i++)
    {
      int j = 0;
      for (j = 0; j < 12; j++)
	{
	  if (fds[i][j] != NULL)
	    {
	      fclose(fds[i][j]);
	      printf("Wrote %d-%02d.log.gz\n", i, j+1);
	    }
	}
    }
}
