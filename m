From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sat, 24 Jan 2009 19:21:27 -0500
Subject: [PATCH update2] Convert vgreduce to use vg_read_for_update.
In-Reply-To: <1232833560-2964-2-git-send-email-dwysocha@redhat.com>
References: <1232833560-2964-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1232842888-10752-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Fix unlock_vg() in error paths.



