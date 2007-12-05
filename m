From: Jim Meyering <jim@meyering.net>
Date: Wed, 05 Dec 2007 10:51:11 +0100
Subject: [PATCH] LVM2: fix t-000-basic.sh
In-Reply-To: <4755D061.6080906@ce.jp.nec.com> (Jun'ichi Nomura's message of
	"Tue, 04 Dec 2007 17:10:41 -0500")
References: <4755D061.6080906@ce.jp.nec.com>
Message-ID: <87eje14ghc.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

"Jun'ichi Nomura" <j-nomura@ce.jp.nec.com> wrote:
> Hi,
>
> The testcase t-000-basic.sh doesn't work for me.
>   - It executes 'lvm' and sees the return code.
>     However, when readline support is enabled, it waits for user input.
>     So 'make check' stalls.
>   - It expects return code '3'.
>     However, with the current CVS head, any of the followings return '0':
>       o 'lvm' without readline support
>       o 'lvm version'
>       o 'lvm < /dev/null'
>
> The purpose of the test is to check if lvm is built.
> I think the test can be achieved with 'lvm version'.
>
> Thanks,

Thank you.
I committed it with the following log entry:
(FYI, the last two lines are added automatically when I run
git-cvsexportcommit to export the commit from my git-based
tree to the mast cvs-based one)

        Avoid spurious test failure when compiled with readline support.

        * test/t-000-basic.sh: Invoke initial test of lvm with its "version"
        argument, so that the behavior of the tool doesn't depend on whether
        readline was enabled at configure time.


        Author: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
        Committer: Jim Meyering <meyering@redhat.com>


