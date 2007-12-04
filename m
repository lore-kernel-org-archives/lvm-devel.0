From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 04 Dec 2007 17:10:41 -0500
Subject: [PATCH] LVM2: fix t-000-basic.sh
Message-ID: <4755D061.6080906@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

The testcase t-000-basic.sh doesn't work for me.
  - It executes 'lvm' and sees the return code.
    However, when readline support is enabled, it waits for user input.
    So 'make check' stalls.
  - It expects return code '3'.
    However, with the current CVS head, any of the followings return '0':
      o 'lvm' without readline support
      o 'lvm version'
      o 'lvm < /dev/null'

The purpose of the test is to check if lvm is built.
I think the test can be achieved with 'lvm version'.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-fix-t-000-basic.patch
Type: text/x-patch
Size: 606 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071204/4aba7479/attachment.bin>
