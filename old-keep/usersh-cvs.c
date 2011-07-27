#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

int main (int argc, char *argv[]) {
  if (argc != 2+1
      || (strcmp(argv[1], "-c") != 0)
      || (strcmp(argv[2], "cvs server") != 0))
    {
      fprintf(stderr, "We only allow the \"cvs server\" command here :)\n");
      return 1;
    }
  
  {
    char *const exec_args[] = { "cvs", "server", NULL };
    execv ("/usr/bin/cvs", exec_args);
  }

  /* If we're here, there was an error in execv(3) */
  fprintf(stderr, "Server error: %s. "
	  "Please contact the system administrators!\n", strerror (errno));
  return 1;
}
/* compile-command:  gcc -Wall -ansi -pedantic -o cvssh usersh-cvs.c */
