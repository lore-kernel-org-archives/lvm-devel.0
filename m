From: 程智星 <zhixing@nj.iscas.ac.cn>
Date: Wed, 26 Jul 2023 14:25:36 +0800 (GMT+08:00)
Subject: Problems encountered in compiling lvm packages using the musl Toolchain
Message-ID: <5b660067.3cd51.18990dfd7d3.Coremail.zhixing@nj.iscas.ac.cn>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

hi?friend?

I encountered the following problems when compiling lvm packages using the musl Toolchain:

Question 1 ?


| vgimportdevices.c: In function 'vgimportdevices':
| vgimportdevices.c:148:30: error: 'LOCK_EX' undeclared (first use in this function); did you mean 'LOCKED'?
|   148 |  if (!lock_devices_file(cmd, LOCK_EX)) {
|       |                              ^~~~~~~
|       |                              LOCKED
| vgimportdevices.c:148:30: note: each undeclared identifier is reported only once for each function it appears in

About LOCK_EX definition is in file.h, I can compile this package by adding this Header file in vgimportdevices.c:

#include <sys/file.h>




Could you add this Header file to our source code to fix this problem or do you have a better solution?




Looking forward to your reply!








-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230726/61a8c89c/attachment.htm>
