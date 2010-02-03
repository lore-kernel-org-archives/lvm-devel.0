From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 3 Feb 2010 09:25:28 -0500
Subject: add %ORIGIN support to the --extents option
In-Reply-To: <1265145451-17708-1-git-send-email-snitzer@redhat.com>
References: <1265145451-17708-1-git-send-email-snitzer@redhat.com>
Message-ID: <20100203142528.GA5448@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Feb 02 2010 at  4:17pm -0500,
Mike Snitzer <snitzer@redhat.com> wrote:

> Allow the number of logical extents to be expressed as a percentage of
> the total space in the Origin Logical Volume with the suffix %ORIGIN.

I've committed this %ORIGIN support.  I just wanted to share that it was
motivated by a need for it in the yum-utils' fs-snapshot plugin (helps
users craft more usable default snapshot LV sizes).  I recently posted
3 patches to add LVM snapshot support to the yum-utils fs-snapshot
plugin:

http://lists.baseurl.org/pipermail/yum-devel/2010-February/006603.html


