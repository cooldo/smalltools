#include <stdio.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <errno.h>
#include <linux/input.h>
#include <string.h>

int main(int argc, char *argv[])
{
	int fd;
	fd_set rds;
	int ret;

	struct input_event event;

	if (argc < 2)
	{
		return 0;
	}

	fd = open( argv[1], O_RDONLY );
	if ( fd < 0 )
	{
		return -1;
	}
	while ( 1 )
	{
		FD_ZERO( &rds );
		FD_SET( fd, &rds );
		ret = select( fd + 1, &rds, NULL, NULL, NULL );
		if ( ret < 0 )
		{
			return -1;
		}
		else if ( FD_ISSET( fd, &rds ) )
		{
			printf("%s\n", argv[1]);
			break;
		}
	}
	close( fd );
	return 0;
}