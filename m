From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 19 Jul 2010 22:00:07 +0100
Subject: [PATCH] check for running cluster log daemon, not just log module
In-Reply-To: <1F3F1266-F403-4350-8669-F3186B4EA0B9@redhat.com>
References: <1279291187.4957.2.camel@hydrogen.msp.redhat.com>
	<20100716161656.GA6506@agk-dp.fab.redhat.com>
	<1F3F1266-F403-4350-8669-F3186B4EA0B9@redhat.com>
Message-ID: <20100719210007.GC19063@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The function is named 'daemon_is_running', so it really should
still give the correct answer if the daemon is *not* running
but a previous instance left the file behind for any reason.
I.e. validate that the PID in the file does in fact still
exist and have that lockfile open.

>> Yes - check /proc/<pid>/fd/*  if available?

Read pidfile to get PID.

List /proc/<pid>/fd/* and check that one of them (a quick code
audit might even enable you to guarantee which one and pass it
in as another parameter) points back at the file.

The daemon name doesn't really matter in this: if someone creates other
software that uses *our* lockfile then they've got bigger problems, but yes,
you could pass that in and check that too.

Alasdair


