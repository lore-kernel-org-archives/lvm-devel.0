From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 13 Oct 2010 22:42:57 +0100
Subject: [PATCH] lvconvert: provide useful error when snapshot-merge target missing
In-Reply-To: <4CB6034D.5080603@redhat.com>
References: <20101013185302.GA2944@redhat.com> <4CB6034D.5080603@redhat.com>
Message-ID: <20101013214257.GC32395@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Oct 13, 2010 at 09:06:53PM +0200, Milan Broz wrote:
> I think this will break shared (external) segment module ABI.

Indeed - we make no guarantees for that ABI and don't even bother 
versioning it.  We don't believe there are any out-of-tree users.

Alasdair


