/*************************** GMTIME ************************************/ 

#include <time.h>
#include <string.h>

struct tm *gmtime_r(time_t *timep, struct tm *result)
{
	__tm_conv(result, timep, 0);
	return result;
}
