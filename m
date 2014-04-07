From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 7 Apr 2014 14:36:58 +0100
Subject: master - thin: Support thin_check --clear-needs-check-flag.
In-Reply-To: <20140407130448.GA24460@agk-dp.fab.redhat.com>
References: <20140404012333.25D0B6109F@fedorahosted.org>
	<534270D1.2040609@redhat.com>
	<20140407130448.GA24460@agk-dp.fab.redhat.com>
Message-ID: <20140407133658.GB24460@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 07, 2014 at 02:04:48PM +0100, Alasdair G Kergon wrote:
>   - Under precisely what circumstances would a user find a 'needs check' flag needs clearing by lvm?
 
After a bit more discussion, I think documentation is the best answer
for now.

Proper recovery from the current failure modes (disk i/o error, out of
metadata space etc.) that lead to this flag getting set are nearly
always still going to require manual intervention anyway, and so I don't
think clearing the flag automatically gains us anything from the lvm2
point of view until we can automatically distinguish between the failure
modes and handle them.

Alasdair


