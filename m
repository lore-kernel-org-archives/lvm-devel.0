From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 8 Jul 2011 03:16:34 +0100
Subject: --alloc seems to be ignored by lvextend
In-Reply-To: <201107071501.39342.benscott@nwlink.com>
References: <201107071158.46782.benscott@nwlink.com>
	<20110707194049.GC7477@agk-dp.fab.redhat.com>
	<201107071501.39342.benscott@nwlink.com>
Message-ID: <20110708021634.GD7477@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Jul 07, 2011 at 03:01:39PM -0700, ben wrote:
> bedroom:~/stuff# lvextend --alloc anywhere --size +1g  newvg/test
> It is still "normal" here:
>   test newvg -wn-a- 2.00g                                      
 
That's correct:
   lvchange changes the default value for that LV permanently.
   - That is what lvs displays.
   With lvextend, you are just overriding that default for the single command.

Alasdair


