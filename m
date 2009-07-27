From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 27 Jul 2009 16:01:43 -0400
Subject: [PATCH 0/6] Add final liblvm APIs for functional freeze, update tests
Message-ID: <1248724909-20369-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Add skeletons for the not yet implemented lvresize and pvresize APIs.
Add a lvm_config_override API which allows the caller to pass a string,
similar to --config, and override the LVM configuration.  This is useful
to filter devices, which anaconda uses.
Finally, update the tests and fix a couple small bugs in lvm_reload_config.

We think this covers the functionality anaconda needs.


