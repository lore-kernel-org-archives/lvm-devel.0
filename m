From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 25 Oct 2010 18:10:40 -0400
Subject: [RFC][PATCH] update vgchange's handling of -a, --refresh, --monitor and --poll
In-Reply-To: <20101025220251.GA6858@redhat.com>
References: <20101025220251.GA6858@redhat.com>
Message-ID: <20101025221039.GA7417@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Oct 25 2010 at  6:02pm -0400,
Mike Snitzer <snitzer@redhat.com> wrote:

> Update vgchange to have nearly comparable processing of -a, --refresh,
> --monitor and --poll

Meant to say:

Update vgchange to have lvchange like processing of -a, --refresh,
--monitor and --poll

(I said "nearly comparable" before because I didn't make vgchange -ay
control polling like lvchange -ay does, like noted in this patch's last
FIXME)

Mike


