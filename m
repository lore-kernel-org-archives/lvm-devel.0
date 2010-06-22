From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 22 Jun 2010 15:04:05 +0100
Subject: [PATCH 25/35] Make vg->mda_copies persistent in on disk vg metadata.
In-Reply-To: <1277203009.2484.66.camel@f10-node1>
References: <1277175968-9661-19-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-20-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-21-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-22-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-23-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-24-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-25-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-26-git-send-email-dwysocha@redhat.com>
	<4C2071F0.1030204@redhat.com> <1277203009.2484.66.camel@f10-node1>
Message-ID: <20100622140405.GA14902@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Indeed, that version number would only be changed if chose to make a major
change that broke compatibility.

Generally, if people access LVM metadata with older tools than the ones
used to write it they can expect any new features in the metadata to get
dropped - but the code should still work OK.  Sometimes there'll be
warning messages; other times not.

We do try to phase-in new features, so code goes in that recognises the
new feature several releases before the feature can be enabled by default.

So for now, this new feature will require positive action by the
sysadmin to enable.  (E.g. editing lvm.conf or using new cmdline
options.)

Alasdair


