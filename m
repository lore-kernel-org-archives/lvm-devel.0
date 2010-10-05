From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 6 Oct 2010 00:49:45 +0100
Subject: [PATCH] dmeventd -R (restart; BZ 454618)
In-Reply-To: <BCC2498C-1B82-4462-A9FE-27823E22DEA2@redhat.com>
References: <87sk0kncit.fsf@twilight.int.mornfall.net.>
	<BCC2498C-1B82-4462-A9FE-27823E22DEA2@redhat.com>
Message-ID: <20101005234945.GG1200@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

>> +	kill(pid, 9);

I'm paranoid about code like that, and want to see everything reasonably
possible done to ensure it can only kill the process it should and
any possible races are clearly documented and defended against.
 
Alasdair


