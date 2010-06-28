From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 28 Jun 2010 14:36:03 +0100
Subject: [PATCH 37/38] Update example.conf.in to describe vgmetadatacopies.
In-Reply-To: <1277520789-6808-38-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-29-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-30-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-31-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-32-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-33-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-34-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-35-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-36-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-37-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-38-git-send-email-dwysocha@redhat.com>
Message-ID: <20100628133603.GB14902@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jun 25, 2010 at 10:53:08PM -0400, Dave Wysochanski wrote:
> Update example.conf to note the string value.  Special care
> must be taken with the string and numeric value - the numbers
> must be enclosed in "'s, so this is noted in the comments.
 
It's quite unnatural to require numbers to be in quotes.
Find another way to do what you need.

Alasdair


