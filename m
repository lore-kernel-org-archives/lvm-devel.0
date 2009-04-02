From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 2 Apr 2009 15:37:36 +0100
Subject: [PATCH] fix debugging version of dm_pool_grow_object to properly use delta=0
In-Reply-To: <49D4C97D.5020304@redhat.com>
References: <49D4C97D.5020304@redhat.com>
Message-ID: <20090402143736.GR13664@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Apr 02, 2009 at 04:19:41PM +0200, Milan Broz wrote:
> Fix debug poll grow object to properly support delta=0
 
It's a bit obfuscated.

Maybe try extra_size instead of delta within the fn, and new_size instead of size?

Alasdair
-- 
agk at redhat.com


