From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 10 Mar 2010 10:26:11 +0100
Subject: PATCH: Replace mlockall() with interal implementation
In-Reply-To: <Pine.LNX.4.64.1003100334531.13100@hs20-bc2-1.build.redhat.com>
References: <4B87D947.4060300@redhat.com>
	<4B87F062.8090407@redhat.com>	<4B90D58C.7090501@redhat.com>
	<Pine.LNX.4.64.1003100334531.13100@hs20-bc2-1.build.redhat.com>
Message-ID: <4B9765B3.4020801@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10.3.2010 10:07, Mikulas Patocka wrote:
> The whole thing is bad.
> 
> First, you must understand the users' priorities:
> 
> priority #1: the computer doesn't crash
> 
> priority #2: lvm takes less memory
> 
> priority #3: the user sees localized error messages
> 
> 
> The problem with this selective mlocking (mlock everything except locale) 
> is that it is hard to review the call graph that no locale data is being 
> accessed while the memory is locked.
> 
> For example, if something calls isdigit() or isalpha(), it is accessing 
> locale. If you call sprintf or sscanf, it may access locale as well. 
> strcasecmp accesses locale as well.
> 

In reallity it's really not all THAT bad - the only problem here is it is a
bit time consuming task - I'm learing a bit about cflow usage which 'should'
be able to probably prove the thing mathematically...

Anyway here is the list of all glibc symbols we use - where only tiny fraction
is in use while we are in 'locked' state - and again only tiny portion of them
is influenced by locales - of course we need to audit code during the
locked state and but it's not that hard - and we said that already...

We could easily make a wrapper around native glibc calls - and get coverage
from our testsuit - so we know in great detail which functions are in use.
(developers should check lcov outputs and regularly check coverage percentage
from test-suit).

abort@@GLIBC_2.0
access@@GLIBC_2.0
alphasort64@@GLIBC_2.2
__assert_fail@@GLIBC_2.0
closedir@@GLIBC_2.0
close@@GLIBC_2.0
closelog@@GLIBC_2.0
connect@@GLIBC_2.0
ctime@@GLIBC_2.0
ctime_r@@GLIBC_2.0
__ctype_b_loc@@GLIBC_2.3
__ctype_tolower_loc@@GLIBC_2.3
__ctype_toupper_loc@@GLIBC_2.3
dirname@@GLIBC_2.0
dlclose@@GLIBC_2.0
dlerror@@GLIBC_2.0
dlopen@@GLIBC_2.1
dlsym@@GLIBC_2.0
__errno_location@@GLIBC_2.0
execvp@@GLIBC_2.0
exit@@GLIBC_2.0
_exit@@GLIBC_2.0
fclose@@GLIBC_2.1
fcntl@@GLIBC_2.0
fdopen@@GLIBC_2.1
ferror@@GLIBC_2.0
fflush@@GLIBC_2.0
fgets@@GLIBC_2.0
flock@@GLIBC_2.0
fopen@@GLIBC_2.1
fopen64@@GLIBC_2.1
fork@@GLIBC_2.0
fprintf@@GLIBC_2.0
fputc@@GLIBC_2.0
fputs@@GLIBC_2.0
free@@GLIBC_2.0
fsync@@GLIBC_2.0
fwrite@@GLIBC_2.0
__fxstat64@@GLIBC_2.2
__getdelim@@GLIBC_2.0
getenv@@GLIBC_2.0
geteuid@@GLIBC_2.0
gethostname@@GLIBC_2.0
getopt_long@@GLIBC_2.0
getpagesize@@GLIBC_2.0
getpid@@GLIBC_2.0
getppid@@GLIBC_2.0
getpriority@@GLIBC_2.0
getrlimit64@@GLIBC_2.2
getuid@@GLIBC_2.0
ioctl@@GLIBC_2.0
_IO_getc@@GLIBC_2.0
__isoc99_sscanf@@GLIBC_2.7
__libc_start_main@@GLIBC_2.0
link@@GLIBC_2.0
lseek64@@GLIBC_2.1
__lxstat64@@GLIBC_2.2
malloc@@GLIBC_2.0
mallopt@@GLIBC_2.0
memcpy@@GLIBC_2.0
memset@@GLIBC_2.0
mkdir@@GLIBC_2.0
mlockall@@GLIBC_2.0
mlock@@GLIBC_2.0
mmap64@@GLIBC_2.1
munlockall@@GLIBC_2.0
munlock@@GLIBC_2.0
munmap@@GLIBC_2.0
opendir@@GLIBC_2.0
openlog@@GLIBC_2.0
open64@@GLIBC_2.1
optarg@@GLIBC_2.0
optind@@GLIBC_2.0
putchar@@GLIBC_2.0
qsort@@GLIBC_2.0
rand_r@@GLIBC_2.0
readdir64@@GLIBC_2.2
read@@GLIBC_2.0
readlink@@GLIBC_2.0
realloc@@GLIBC_2.0
rename@@GLIBC_2.0
rmdir@@GLIBC_2.0
scandir64@@GLIBC_2.2
setenv@@GLIBC_2.0
setlocale@@GLIBC_2.0
setpriority@@GLIBC_2.0
setsid@@GLIBC_2.0
sigaction@@GLIBC_2.0
sigaddset@@GLIBC_2.0
sigdelset@@GLIBC_2.0
sigfillset@@GLIBC_2.0
siginterrupt@@GLIBC_2.0
sigismember@@GLIBC_2.0
signal@@GLIBC_2.0
sigprocmask@@GLIBC_2.0
sleep@@GLIBC_2.0
snprintf@@GLIBC_2.0
socket@@GLIBC_2.0
sprintf@@GLIBC_2.0
sscanf@@GLIBC_2.0
stderr@@GLIBC_2.0
stdin@@GLIBC_2.0
stdout@@GLIBC_2.0
strcasecmp@@GLIBC_2.0
strcat@@GLIBC_2.0
strcmp@@GLIBC_2.0
strcpy@@GLIBC_2.0
__strdup@@GLIBC_2.0
strerror@@GLIBC_2.0
strchr@@GLIBC_2.0
strlen@@GLIBC_2.0
strncmp@@GLIBC_2.0
strncpy@@GLIBC_2.0
strrchr@@GLIBC_2.0
strstr@@GLIBC_2.0
strtod@@GLIBC_2.0
strtol@@GLIBC_2.0
strtoll@@GLIBC_2.0
strtoul@@GLIBC_2.0
symlink@@GLIBC_2.0
sync@@GLIBC_2.0
time@@GLIBC_2.0
umask@@GLIBC_2.0
uname@@GLIBC_2.0
unlink@@GLIBC_2.0
unsetenv@@GLIBC_2.0
vfprintf@@GLIBC_2.0
vsnprintf@@GLIBC_2.0
vsyslog@@GLIBC_2.0
wait4@@GLIBC_2.0
write@@GLIBC_2.0
__xpg_basename@@GLIBC_2.0
__xstat@@GLIBC_2.0
__xstat64@@GLIBC_2.2



The final solution here is to reimplement those function we use during mlock()
with internal lvm implementation - so you would be 100%  sure there is no
future problem.

BTW even current mlockall() solution definitely doesn't cover the case, when
glibc decides to do something unexpected during this state - i.e. open another
acceleration mmap file.


> implementation, we can't prove that all future sprintf implementations 
> won't call isdigit() or other is* functions when parsing the string.

glibc might have bugs, kernel might have bugs, lvm might have bugs...
even CPU, memory, disk could have hardware bugs... :)

Zdenek


