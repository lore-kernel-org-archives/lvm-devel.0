From: Leo Yan <leo.yan@linaro.org>
Date: Thu, 25 Jun 2020 17:34:12 +0800
Subject: Question: LVM2 testing with sanlock lock manager
Message-ID: <20200625093411.GB19777@leoy-ThinkPad-X240s>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi there,

I have one question for LVM test suites with sanlock locking manager.
After tried both the master branch and with the LVM v2 (with the tag
'v2_02_187'), the testing seems to me is fragile.

I observed some below issues:

- The sanlock daemon preparation script
  test/shell/aa-lvmlockd-sanlock-prepare.sh has several issues, e.g.
  the dmsetup command cannot work well for global lock; the
  gl_file.img is stored in the temporary folder and it will be removed
  after the script aa-lvmlockd-sanlock-prepare.sh is finished, so
  gl_file.img cannot be used cross all sequential test cases.  Thus
  the global lock will malfunction for this case.

  Have sent related patches to lvm-devel mailing list for this.

- I also compared the testing result between DLM and sanlock, if I
  using DLM as the locking scheme, the testing result is quite
  reliable.  But for sanlock related testing, the testing cases have
  many failures, even after fixed the observed issues in
  aa-lvmlockd-sanlock-prepare.sh, still can see many failures.

  I used the command as below:
  make check_lvmlockd_sanlock LVM_TEST_BACKING_DEVICE=/dev/sdj3 S=component-cache.sh

  From the testing I found, component-cache.sh is easily cause stuck
  at the last command to remove VG and after the testing case
  lvconvert-cache-chunks.sh the almost later cases fail.  So the final
  testing result is:
  ### 330 tests: 34 passed, 98 skipped, 0 timed out, 1 warned, 197 failed

Could you kindly confirm if I miss something (configurations, or
should co-work with DLM) for sanlock related testing?

Thank you,
Leo


