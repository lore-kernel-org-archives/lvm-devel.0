From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 10 Jan 2008 14:53:13 -0500
Subject: [PATCH lvconvert 0/11] Additional fixes and changes to lvconvert restructure
In-Reply-To: <20080110184021.GP3510@agk.fab.redhat.com>
References: <477E48D8.4050404@ce.jp.nec.com>
	<20080110184021.GP3510@agk.fab.redhat.com>
Message-ID: <478677A9.4040605@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon wrote:
> On Fri, Jan 04, 2008 at 09:55:20AM -0500, Jun'ichi Nomura wrote:
>> [10/11] Warn if lvconvert needs activation to complete conversion
> 
> Not sure here - should we perform the activation immediately?

I think it's ok to leave it for the users decision.
IMO, if the LV is not active when lvconvert is executed,
there is likely a reason the LV is not activated.

It followed the way linear-to-mirror conversion used to work.
If linear inactive LV is converted to mirror, syncing doesn't
start until it's activated.
(With that regard, maybe I should have let lvconvert take
  '--wait' rather than '--background' and return immediately
 by default.)

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


