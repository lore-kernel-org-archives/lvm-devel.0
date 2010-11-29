From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 20:04:52 +0000
Subject: [PATCH 05/29] Test *buf for NULL
In-Reply-To: <c243f6bafee4be13671b45b6b0b902d4b158630e.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<c243f6bafee4be13671b45b6b0b902d4b158630e.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129200451.GS29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:09AM +0100, Zdenek Kabelac wrote:
> As we reallocate *buf in CLVMD_CMD_TEST we need to test for NULL
> to print status to avoid printing to NULL buffer.
> (realloc() == NULL & status != 0)

Ack for now.

> CHECKME:
> General question - what is supposed to be written in *retlen for  *buf == NULL?
 
The callers initialise it to 0 so it should stay 0 and the callers ought to
cope...

Alasdair


