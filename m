From: Joe Thornber <thornber@redhat.com>
Date: Tue, 29 Mar 2011 12:48:45 +0100
Subject: [PATCH 1/1] fallback 'unit-test' target for those who don't have ruby installed
Message-ID: <1301399325.2949.1.camel@ubuntu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

commit 79bb0560381791c3d90cbcfcf89a0f61da2f15e1
Author: Joe Thornber <joe.thornber@gmail.com>
Date:   Tue Mar 29 12:44:36 2011 +0100

    o Change the --enable-testing configure option to
--enable-ruby-testing
    o Add fallback 'make unit-test' implementation using bash

diff --git a/Makefile.in b/Makefile.in
index f7e34f4..b0e5511 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -131,11 +131,8 @@ endif
 
 endif
 
-ifeq ("$(TESTING)", "yes")
-# testing and report generation
-RUBY=ruby1.9 -Ireport-generators/lib -Ireport-generators/test
-
-.PHONEY: unit-test ruby-test test-programs
+# testing targets
+.PHONEY: unit-test test-programs memcheck
 
 # FIXME: put dependencies on libdm and liblvm
 test-programs:
@@ -143,6 +140,9 @@ test-programs:
 	cd unit-tests/datastruct && $(MAKE)
 	cd unit-tests/mm && $(MAKE)
 
+ifeq ("$(RUBY_TESTING)", "yes")
+RUBY=ruby1.9 -Ireport-generators/lib -Ireport-generators/test
+
 unit-test: test-programs
 	$(RUBY) report-generators/unit_test.rb $(shell find . -name TESTS)
 	$(RUBY) report-generators/title_page.rb
@@ -153,4 +153,7 @@ memcheck: test-programs
 
 ruby-test:
 	$(RUBY) report-generators/test/ts.rb
+else
+unit-test: test-programs
+	scripts/unit-test $(shell find . -name TESTS)
 endif
diff --git a/configure.in b/configure.in
index c531c8a..91626f6 100644
--- a/configure.in
+++ b/configure.in
@@ -754,12 +754,12 @@ fi

################################################################################
 dnl -- Enable testing
 AC_MSG_CHECKING(whether to enable unit testing)
-AC_ARG_ENABLE(testing,
-              AC_HELP_STRING(--enable-testing, [enable testing targets
in the makefile]),
-              TESTING=$enableval, TESTING=no)
-AC_MSG_RESULT($TESTING)
+AC_ARG_ENABLE(ruby-testing,
+              AC_HELP_STRING(--enable-ruby-testing, [enable ruby
testing framework]),
+              RUBY_TESTING=$enableval, RUBY_TESTING=no)
+AC_MSG_RESULT($RUBY_TESTING)
 
-if test "$TESTING" = yes; then
+if test "$RUBY_TESTING" = yes; then
    AC_PATH_PROG(RUBY19, ruby1.9)
    AC_PATH_PROG(VALGRIND, valgrind)
    if test -z "$RUBY19" -o -z "$VALGRIND"; then
@@ -1363,7 +1363,7 @@ AC_SUBST(SELINUX_PC)
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
-AC_SUBST(TESTING)
+AC_SUBST(RUBY_TESTING)
 AC_SUBST(UDEV_LIBS)
 AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
diff --git a/make.tmpl.in b/make.tmpl.in
index 5380b5e..0bdcd48 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -44,7 +44,7 @@ PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
 SELINUX_LIBS = @SELINUX_LIBS@
 UDEV_LIBS = @UDEV_LIBS@
-TESTING = @TESTING@
+RUBY_TESTING = @RUBY_TESTING@
 
 # Setup directory variables
 prefix = @prefix@
diff --git a/scripts/unit-test b/scripts/unit-test
new file mode 100755
index 0000000..afd9abe
--- /dev/null
+++ b/scripts/unit-test
@@ -0,0 +1,58 @@
+#!/bin/bash
+
+export LD_LIBRARY_PATH=$PWD/libdm:$LD_LIBRARY_PATH
+TEST_TOOL=''
+test_output=$PWD/test.output
+total=0
+pass=0
+
+function run_test() {
+    desc=$1
+    cmd=$2
+
+    echo -n "    $desc ... "
+
+    echo "=============" >> $test_output
+    echo '*** '$desc >> $test_output
+
+    if (eval $cmd) >> $test_output 2>&1; then
+ 	echo pass
+	pass=$((pass + 1))
+    else
+     	echo FAIL
+    fi
+}
+
+function run_tests() {
+    schedule_file=$1
+    pushd $(dirname $schedule_file) > /dev/null
+
+    OIFS=$IFS; IFS=:
+
+    while read desc cmd
+    do
+	run_test "$desc" "$cmd"
+	total=$((total + 1))
+
+    done < <(sed -e 's/\#.*//g' -e '/^[ ]*$/d' <(cat TESTS; echo) )
+    echo
+
+    IFS=$OIFS
+
+    popd > /dev/null
+}
+
+rm $test_output
+touch $test_output
+for s in $@; do
+    echo "Running tests in $(dirname $s)"
+    run_tests $s
+done
+
+echo "========================"
+echo $pass/$total tests passed
+echo "========================"
+
+if [ ! $total -eq $pass ]; then
+    exit 1
+fi
\ No newline at end of file



