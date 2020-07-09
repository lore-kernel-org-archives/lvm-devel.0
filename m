From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 9 Jul 2020 10:54:29 +0200
Subject: master - multipathd: fix fd leak when iscsi device logs in
In-Reply-To: <6eb10725-456f-de68-e927-1f5a9771c16c@huawei.com>
References: <6eb10725-456f-de68-e927-1f5a9771c16c@huawei.com>
Message-ID: <86d8307c-1747-2254-4f87-fac36f0d51ca@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 09. 07. 20 v 9:02 lixiaokeng napsal(a):
> When one iscsi device logs in and logs out several times, the
> number of fd, which points to '/dev/mapper/control', increases in
> /proc/<multipathd-pid>/fd as follows,
> [root at localhost fd]# ll | grep control

> diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
> index 7ad549c..7168369 100644
> --- a/libdm/ioctl/libdm-iface.c
> +++ b/libdm/ioctl/libdm-iface.c
> @@ -23,6 +23,7 @@
>   #include <sys/ioctl.h>
>   #include <sys/utsname.h>
>   #include <limits.h>
> +#include <pthread.h>
> 
>   #ifdef __linux__
>   #  include "libdm/misc/kdev_t.h"
> @@ -81,6 +82,7 @@ static dm_bitset_t _dm_bitset = NULL;
>   static uint32_t _dm_device_major = 0;
> 
>   static int _control_fd = -1;
> +static pthread_mutex_t _control_fd_mutex = PTHREAD_MUTEX_INITIALIZER;
>   static int _hold_control_fd_open = 0;
>   static int _version_checked = 0;
>   static int _version_ok = 1;
> @@ -404,10 +406,19 @@ static void _close_control_fd(void)
>   #ifdef DM_IOCTLS
>   static int _open_and_assign_control_fd(const char *control)
>   {
> +	pthread_mutex_lock(&_control_fd_mutex);
> +
> +	if (_control_fd != -1) {



Hi

libdm is not pthread aware/safe library.

So the fix needs to happen on libdm user-side to prevent race call of this 
function.


Zdenek


