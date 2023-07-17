From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Mon, 17 Jul 2023 12:31:38 +0000
Subject: [Git][lvmteam/lvm2][main] tests: new logic for repair
Message-ID: <64b534aa7ca11_28a827844597@gitlab-sidekiq-low-urgency-cpu-bound-v2-58b657dc5c-jhf84.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
32b2e416 by Zdenek Kabelac at 2023-07-17T14:30:39+02:00
tests: new logic for repair

meta name deduced from cachepool name.

- - - - -


1 changed file:

- test/shell/lvconvert-repair-cache.sh


Changes:

=====================================
test/shell/lvconvert-repair-cache.sh
=====================================
@@ -67,14 +67,14 @@ lvchange -an $vg/$lv1
 lvconvert --repair $vg/$lv1
 
 lvs -a $vg
-check lv_exists $vg ${lv1}_meta0
+check lv_exists $vg cpool_cpool_meta0
 
 eval "$(lvs -S 'name=~_pmspare' -a --config 'report/mark_hidden_devices=0' -o name --noheading --nameprefixes $vg)"
 lvremove -f --yes "$vg/$LVM2_LV_NAME"
 
 # check --repair without creation of _pmspare device
 lvconvert --repair --poolmetadataspare n $vg/$lv1
-check lv_exists $vg ${lv1}_meta1
+check lv_exists $vg cpool_cpool_meta1
 
 # check no _pmspare has been created in previous --repair
 test "0" = "$(lvs -S 'name=~_pmspare' -a -o name --noheading --nameprefixes $vg | wc -l)"



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/32b2e416cc7ecaee013ebecf0ac507622535ce2b

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/32b2e416cc7ecaee013ebecf0ac507622535ce2b
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230717/b16c0287/attachment.htm>
