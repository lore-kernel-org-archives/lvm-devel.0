From: David Teigland <teigland@redhat.com>
Date: Tue, 27 Apr 2021 17:23:23 -0500
Subject: [LVM2 RFCv1 0/5] Enable In-Drive-Mutex Locking scheme
In-Reply-To: <20210425022241.5055-1-leo.yan@linaro.org>
References: <20210425022241.5055-1-leo.yan@linaro.org>
Message-ID: <20210427222323.GA15230@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Apr 25, 2021 at 10:22:36AM +0800, Leo Yan wrote:
> This patch set enables the In-Drive-Mutex (IDM) locking scheme.

Hi, nice work, I'll begin looking through this in the next few days.
It seems to closely follow the existing pattern of sanlock and dlm,
so it should be pretty easy to follow.

Dave


