From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 21 Jan 2014 13:04:42 -0500
Subject: master - tests: more testing for online thin metadata resize
In-Reply-To: <20140121125418.6F77260DB2@fedorahosted.org>
References: <20140121125418.6F77260DB2@fedorahosted.org>
Message-ID: <20140121180442.GA2917@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jan 21 2014 at  7:54am -0500,
Zdenek Kabelac <zkabelac@fedoraproject.org> wrote:

> Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=efe36fcd43f243de5cdd5838c284b0e5a24ac893
> Commit:        efe36fcd43f243de5cdd5838c284b0e5a24ac893
> Parent:        22d9daff12b73e72f520ea70f416e1d3057ae740
> Author:        Zdenek Kabelac <zkabelac@redhat.com>
> AuthorDate:    Tue Jan 21 10:04:23 2014 +0100
> Committer:     Zdenek Kabelac <zkabelac@redhat.com>
> CommitterDate: Tue Jan 21 13:53:10 2014 +0100
> 
> tests: more testing for online thin metadata resize
> 
> Some more tests for online resize, but it's still disabled
> by default, since kernel doesn't work yet for this feature.

FYI, fix will go into 3.14.  I didn't bump the thin or thin-pool target
versions because no released kernel (be it RHEL or upstream) has seen
the partial fix yet.


