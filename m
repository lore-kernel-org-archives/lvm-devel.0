From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 26 Oct 2010 14:57:59 +0100
Subject: [PATCH 0/5] Fix NULL dereference
In-Reply-To: <cover.1288097372.git.zkabelac@redhat.com>
References: <cover.1288097372.git.zkabelac@redhat.com>
Message-ID: <20101026135759.GL29400@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Oct 26, 2010 at 02:59:21PM +0200, Zdenek Kabelac wrote:
> Updated patchset for NULL pointer dereferences issues reported by clang.
> 
> Unlike the first version - this time less aggresive solution is used.
> INTERNAL_ERRORs are reported in these moments (if they would ever happen),
> and the execution path aborts when such conditions are met.
> Previous version was rather ignoring these paths and could lead to 
> unwanted execution of other code parts.
 
Well the ones I've looked at here seem to be more about dealing with
shortcomings in the static analysis code rather than fixing real bugs.

Alasdair


