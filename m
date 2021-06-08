From: Leo Yan <leo.yan@linaro.org>
Date: Tue, 8 Jun 2021 14:47:02 +0800
Subject: [LVM2 RFCv2 2/5] lvmlockd: idm: Hook Seagate IDM wrapper APIs
In-Reply-To: <022070a6-d656-5ec0-6e5f-d83fa885ad25@suse.com>
References: <20210507022516.143385-1-leo.yan@linaro.org>
	<20210507022516.143385-3-leo.yan@linaro.org>
	<022070a6-d656-5ec0-6e5f-d83fa885ad25@suse.com>
Message-ID: <20210608064702.GA4640@leoy-ThinkPad-X240s>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jun 08, 2021 at 12:58:58PM +0800, heming.zhao at suse.com wrote:

[...]

> > @@ -4603,12 +4781,14 @@ static void client_recv_action(struct client *cl)
> >   	const char *vg_sysid;
> >   	const char *path;
> >   	const char *str;
> > +	struct pvs pvs;
> > +	char buf[11];	/* p a t h [ x x x x ] \0 */
> >   	int64_t val;
> >   	uint32_t opts = 0;
> >   	int result = 0;
> 
> Hello
> 
> SUSE build tools detected a minor compiling warning/error on the array buf[]:
> 
>     [CC] lvmlockd-core.c
> gcc -MT lvmlockd-core.o -MMD -MP -MF lvmlockd-core.d -c -I. -I../.. -I../../include -include configure.h -I../../libdaemon/server -I/usr/include/valgrind  -DHAVE_CONFIG_H -D_FILE_OFFSET_BITS=64  -Wall -Wcast-align -Wfloat-equal -Wformat-security -Winline -Wmissing-format-attribute -Wmissing-include-dirs -Wmissing-noreturn -Wpointer-arith -Wredundant-decls -Wshadow -Wundef -Wwrite-strings -Wclobbered -Wempty-body -Wignored-qualifiers -Wlogical-op -Wtype-limits -Wsync-nand -Wmissing-declarations -Wmissing-prototypes -Wnested-externs -Wold-style-definition -Wstrict-prototypes -Wuninitialized -Wjump-misses-init -Wmissing-parameter-type -Wold-style-declaration -Woverride-init -O2 -g -m64 -fmessage-length=0 -D_FORTIFY_SOURCE=2 -fstack-protector -funwind-tables -fasynchronous-unwind-tables -fPIC -fPIE  -DUSE_SD_NOTIFY  lvmlockd-core.c -o lvmlockd-core.o
> lvmlockd-core.c: In function 'client_thread_main':
> lvmlockd-core.c:4959:37: warning: '%d' directive output may be truncated writing between 1 and 10 bytes into a region of size 6 [-Wformat-truncation=]
>     snprintf(buf, sizeof(buf), "path[%d]", i);
>                                      ^~
> lvmlockd-core.c:4959:31: note: directive argument in the range [0, 2147483647]
>     snprintf(buf, sizeof(buf), "path[%d]", i);
>                                ^~~~~~~~~~
> In file included from /usr/include/stdio.h:862:0,
>                  from ../../device_mapper/all.h:36,
>                  from ../../tools/tool.h:22,
>                  from lvmlockd-core.c:11:
> /usr/include/bits/stdio2.h:64:10: note: '__builtin___snprintf_chk' output between 8 and 17 bytes into a destination of size 11
>    return __builtin___snprintf_chk (__s, __n, __USE_FORTIFY_LEVEL - 1,
>           ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>         __bos (__s), __fmt, __va_arg_pack ());
>         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> make[2]: Leaving directory '/usr/src/packages/BUILD/LVM2.2.03.12/daemons/lvmlockd'
> make[1]: *** [../make.tmpl:353: lvmlockd] Error 2
> make: *** [make.tmpl:353: daemons] Error 2
> error: Bad exit status from /var/tmp/rpm-tmp.y3SyO6 (%build)

Thanks for reporting the issue, Heming.

Please see the patch for fixing the compilation warning:
https://listman.redhat.com/archives/lvm-devel/2021-June/msg00046.html

Thanks,
Leo


