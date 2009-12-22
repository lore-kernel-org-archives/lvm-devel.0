From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 22 Dec 2009 10:51:30 +0000
Subject: [PATCH 3 of 4] Add dm_event_set_timeout/dm_event_unset_timeout interface
In-Reply-To: <20091222021255.GA14900@us.ibm.com>
References: <patchbomb.1260695922@localhost>
	<1c364c686b5e7794e994.1260695925@localhost>
	<20091222021255.GA14900@us.ibm.com>
Message-ID: <20091222105129.GD12491@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Dec 21, 2009 at 06:12:55PM -0800, malahal at us.ibm.com wrote:
> Alasdair suggested to use -1 instead instead of INT_MAX to unregister a
> timeout. This patch supersedes the previous patch.
 
Using a #define, please, rather than hard-coding -1 into the source.

Alasdair


