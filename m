From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sat, 24 Jan 2009 16:45:59 -0500
Subject: [PATCH updated] Convert vgreduce to use vg_read_for_update.
In-Reply-To: <1232619010-4858-9-git-send-email-prockai@redhat.com>
References: <1232619010-4858-9-git-send-email-prockai@redhat.com>
Message-ID: <1232833560-2964-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


One line removed from original patch:
Remove incorrect unlock_vg() in vgreduce_single() error path.
If dev_get_size() fails we don't have the orphan lock yet so
don't try to unlock.


