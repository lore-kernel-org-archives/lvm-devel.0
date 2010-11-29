From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 20:44:38 +0000
Subject: [PATCH 03/29] Remove printing of LCK_CACHE
In-Reply-To: <b66c1e177b64ce40a6c63127b70dc9c01b83d14f.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<b66c1e177b64ce40a6c63127b70dc9c01b83d14f.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129204438.GA29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:07AM +0100, Zdenek Kabelac wrote:
> LCK_CACHE is defined as 0x100 so it cannot be passed through
> unsigned char parameter - remove it from the sprintf code.
 
> If LCK_CLUSTER would be desirable to be printed here - lot of code
> would neet to be reworked.
 
See follow up to commit message.  This one needs more work.

Alasdair


