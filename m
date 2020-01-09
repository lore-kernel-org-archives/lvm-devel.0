From: Leo Yan <leo.yan@linaro.org>
Date: Thu, 9 Jan 2020 16:19:53 +0800
Subject: Question: lvmlockd adopts orphan locks
Message-ID: <20200109081953.GA24047@leoy-ThinkPad-X240s>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi all,

Since the commit 117160b27e51 ("Remove lvmetad") has been merged into
lvm2 git repository, lvmetad is removed.

As side effect, in lvmlockd the function get_lockd_vgs() returns -1.
Thus it's no chance for lvmlockd to adopt orphan locks after the
lvmlockd exits abnormal and relaunch.   If we connect with the sanlock
lock manager, its daemon keeps running on the host and renew all
locks, this would be safe for the in used LV on the host; but on the
other hand, lvmlockd cannot adopt the locks, thus we have no chance to
release related LVM locks anymore.

For this case, I understand we can release locks by directly use low
level sanlock commands, just wander if we have more smooth approach for
lvmlockd to adopt locks and release the locks gracefully after lvmlockd
failure?  Or do I miss anything?

Thanks,
Leo Yan



