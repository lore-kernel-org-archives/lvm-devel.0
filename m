From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 18 May 2009 21:03:49 +0100
Subject: [RFC PATCH] pvmove: do not keep suspended devices behind and try automatically restore previous state
In-Reply-To: <4A0D95B4.1060300@redhat.com>
References: <4A0D95B4.1060300@redhat.com>
Message-ID: <20090518200349.GW5125@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, May 15, 2009 at 06:17:56PM +0200, Milan Broz wrote:
> If pvmove fails activating mirror volume, try restroe to previous state.
> pvmove now keep suspended devices if temporary mirror creation fails.

Ack.

Alasdair


