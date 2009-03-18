From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 18 Mar 2009 19:51:31 +0000
Subject: [PATCH] Add --config to lvm man page.
In-Reply-To: <1237393095-4149-1-git-send-email-dwysocha@redhat.com>
References: <1237393095-4149-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20090318195131.GR3063@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Documenting --config, yes, but only in full - not a partial explanation
that could mislead people.  Give people generic information so they can
determine for themselves whether it is sensible to override any
particular value and any precautions they should take as well as
alternative approaches (like changing system_dir) that avoid the need.
Then give examples of safe and dangerous overrides.

Alasdair
-- 
agk at redhat.com


