From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon,  8 Aug 2016 18:35:36 +0000 (UTC)
Subject: master - man: explain deletion of 1st group member in dmstats.8.in
Message-ID: <20160808183536.263726072E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dad02900f18d3ef9b85d78f2e42434d92e6d84c9
Commit:        dad02900f18d3ef9b85d78f2e42434d92e6d84c9
Parent:        4bcbcdb1a2f276b8139ae0ee7f66ffb342c03f23
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 8 19:29:12 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 8 19:29:12 2016 +0100

man: explain deletion of 1st group member in dmstats.8.in

Although the use of the first region_id in a group to store the
DMS_GROUP=... aux_data tag is an internal implementation detail,
it has a user visible consequence in that deleting this region will
cause the group to disappear: add an explanation of this to the
'group' command and 'Regions, areas, and groups' section.
---
 man/dmstats.8.in |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index befc0d5..2367b8b0 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -600,6 +600,11 @@ the number of histogram bins and their bounds must match exactly.
 
 On success the group list and newly created \fBgroup_id\fP are
 printed to stdout.
+
+The group metadata is stored with the first (lowest numbered)
+\fBregion_id\fP in the group: deleting this region will also delete
+the group and other group members will be returned to their prior
+state.
 .
 .HP
 .CMD_HELP
@@ -672,8 +677,16 @@ each with its own counter set. In this case a summary value for the
 entire region is also available for use in reports.
 
 In addition, one or more regions on one device can be combined into
-a statistics group allowing reporting of aggregate values for all
-regions and areas making up the group.
+a statistics group. Groups allow several regions to be aggregated and
+reported as a single entity; counters for all regions and areas are
+summed and used to report totals for all group members. Groups also
+permit the assignment of an optional alias, allowing meaningful names
+to be associated with sets of regions.
+
+The group metadata is stored with the first (lowest numbered)
+\fBregion_id\fP in the group: deleting this region will also delete
+the group and other group members will be returned to their prior
+state.
 
 By default new regions span the entire device. The \fB\-\-start\fP and
 \fB\-\-length\fP options allows a region of any size to be placed at any


