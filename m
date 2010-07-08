From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 8 Jul 2010 15:59:16 +0100
Subject: [PATCH] clvmd should create its own pid file
In-Reply-To: <4C35CCEB.4020300@redhat.com>
References: <4C35CCEB.4020300@redhat.com>
Message-ID: <20100708145916.GT22664@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Does this work OK with clvmd -S?

Should we have FD_CLOEXEC ?

(See pidfile.c in multipathd.)

Also, let's make it library code rather than copying it from cmirrord.

Alasdair


