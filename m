From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Fri, 12 Aug 2022 14:53:10 +0800
Subject: [PATCH]_vg_read_raw_area: fix segfault caused by using null pointer
Message-ID: <bfb8fec0-e22b-f94d-f096-0e3dff1dd9cb@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When we tested lvm2, the kernel injected various random faults.
Then the following segfault occurs.

#0  0x000055dd6c035550 in _vg_read_raw_area (fid=fid at entry=0x55dd6df41450, vgname=0x55dd6c0f914e "", area=area at entry=0x55dd6df34cf0, vg_fmtdata=0x0, use_previous_vg=use_previous_vg at entry=0x0, precommitted=precommitted at entry=0,
    primary_mda=1, cmd=<optimized out>) at format_text/format-text.c:431
431             if (!vg && !*use_previous_vg) {
Missing separate debuginfos, use: dnf debuginfo-install glibc-2.34-70.h26.eulerosv2r11.x86_64 libaio-0.3.112-2.h1.eulerosv2r11.x86_64 libblkid-2.37.2-5.h7.eulerosv2r11.x86_64 libcap-2.61-1.h1.eulerosv2r11.x86_64 libgcrypt-1.9.4-1.h4.eulerosv2r11.x86_64 libgpg-error-1.43-1.eulerosv2r11.x86_64 libselinux-3.3-1.eulerosv2r11.x86_64 libsepol-3.3-2.h2.eulerosv2r11.x86_64 lz4-1.9.3-2.h1.eulerosv2r11.x86_64 ncurses-libs-6.3-2.h2.eulerosv2r11.x86_64 pcre2-10.39-1.h3.eulerosv2r11.x86_64 readline-8.1-1.eulerosv2r11.x86_64 systemd-libs-249-16.h31.eulerosv2r11.x86_64 xz-libs-5.2.5-2.h1.eulerosv2r11.x86_64
(gdb) bt
#0  0x000055dd6c035550 in _vg_read_raw_area (fid=fid at entry=0x55dd6df41450, vgname=0x55dd6c0f914e "", area=area at entry=0x55dd6df34cf0, vg_fmtdata=0x0, use_previous_vg=use_previous_vg at entry=0x0, precommitted=precommitted at entry=0,
    primary_mda=1, cmd=<optimized out>) at format_text/format-text.c:431
#1  0x000055dd6c0356ac in _vg_read_raw (cmd=<optimized out>, fid=0x55dd6df41450, vgname=<optimized out>, mda=0x55dd6df32180, vg_fmtdata=<optimized out>, use_previous_vg=0x0) at format_text/format-text.c:466
#2  0x000055dd6bfda782 in _online_devs (cmd=cmd at entry=0x55dd6de309e0, do_all=do_all at entry=1, pvscan_devs=pvscan_devs at entry=0x7ffd05527a50, pv_count=pv_count at entry=0x7ffd05527a40,
    complete_vgnames=complete_vgnames at entry=0x7ffd05527a30) at pvscan.c:1342
#3  0x000055dd6bfdc92a in _pvscan_cache_all (argc=0, argv=<optimized out>, complete_vgnames=0x7ffd05527a30, cmd=0x55dd6de309e0) at pvscan.c:1661
#4  pvscan_cache_cmd (cmd=0x55dd6de309e0, argc=<optimized out>, argv=<optimized out>) at pvscan.c:1939
#5  0x000055dd6bfc71cb in lvm_run_command (cmd=cmd at entry=0x55dd6de309e0, argc=<optimized out>, argc at entry=2, argv=<optimized out>, argv at entry=0x7ffd05527e98) at lvmcmdline.c:3278
#6  0x000055dd6bfc8f5e in lvm2_main (argc=2, argv=0x7ffd05527e98) at lvmcmdline.c:3811
#7  0x00007fead4dd5270 in ?? () from /usr/lib64/libc.so.6
#8  0x00007fead4dd531c in __libc_start_main () from /usr/lib64/libc.so.6
#9  0x000055dd6bfa20c5 in _start ()
(gdb) p vg
$1 = (struct volume_group *) 0x0
(gdb) p use_previous_vg
$2 = (unsigned int *) 0x0
(gdb)

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
---
 lib/format_text/format-text.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 07aaa0b28..c1ccdb031 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -428,7 +428,7 @@ static struct volume_group *_vg_read_raw_area(struct cmd_context *cmd,
                                rlocn->checksum,
                                &when, &desc);

-       if (!vg && !*use_previous_vg) {
+       if (!vg && (!use_previous_vg || !*use_previous_vg)) {
                log_warn("WARNING: Failed to read metadata text at %llu off %llu size %llu VG %s on %s",
                         (unsigned long long)(area->start + rlocn->offset),
                         (unsigned long long)rlocn->offset,
--
2.27.0

