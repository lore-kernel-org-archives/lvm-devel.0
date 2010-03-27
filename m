From: Alasdair G Kergon <agk@redhat.com>
Date: Sat, 27 Mar 2010 00:18:14 +0000
Subject: [PATCH] Fix vg_write/vg_commit to not reset position in metadata ring buffer on vgrename
In-Reply-To: <4BAD3CCF.1060302@redhat.com>
References: <4BACBD1F.80101@redhat.com> <1269620108.2508.3.camel@f10-node1>
	<4BAD3CCF.1060302@redhat.com>
Message-ID: <20100327001813.GX5259@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Mar 27, 2010 at 12:01:35AM +0100, Peter Rajnoha wrote:
> How to pass
> that information from the "layer" above through vg_write/vg_commit?

A special value of 'old_name'?

Alasdair


