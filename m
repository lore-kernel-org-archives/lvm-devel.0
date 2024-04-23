Received: from smtpbguseast2.qq.com (smtpbguseast2.qq.com [54.204.34.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 84524802
	for <lvm-devel@lists.linux.dev>; Tue, 23 Apr 2024 00:41:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=54.204.34.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713832881; cv=none; b=knMValuGV3WQ50/F3vUcZY5Il6+fCpEFy2saNP3vp6MZgwgQZ9hexdG0Nh9I/gPTcApf43xwTKV16x6zS6IwFRc06LBl60dy0QRNWoKCttGu2Aa3WErupLLifOWNGV1STzBTLCS3qjG/ud29tUu3OTcRmSkaZIxitXp62FERpHI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713832881; c=relaxed/simple;
	bh=CahRAHSNqgEAchJ+gqzp3Td2nq/nDV9Rs81my3VEduA=;
	h=Date:From:To:Subject:Message-ID:MIME-Version:Content-Type; b=s7tn3xpivZhVHe0jzNpYxCP1iPpp+RVVngzMoPYNiAe2DdDl9Tk3I3KjmxV2NP7NyTbbKo8TR9lnHJNaT3krCcgu6yuqa1PlXTgwJL1ENi7uBuo7J28zMsvacRnMMomVXCaDuJZ9HLyjmVt8b97M19bX+gC6o7N1egy7Pu9Zu8s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=uniontech.com; spf=pass smtp.mailfrom=uniontech.com; arc=none smtp.client-ip=54.204.34.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=uniontech.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=uniontech.com
X-QQ-mid: bizesmtpsz9t1713832863to6grse
X-QQ-Originating-IP: eXGqY8OQnDXYFnFh/y5pmelrzg7wuFwKR6RTeQzrK5w=
Received: from winn-pc ( [113.57.152.160])
	by bizesmtp.qq.com (ESMTP) with SMTP id 0
	for <lvm-devel@lists.linux.dev>; Tue, 23 Apr 2024 08:41:02 +0800 (CST)
X-QQ-SSF: 01400000000000I0I000000A0000000
X-QQ-FEAT: xQoAiglG4R4H7l/inEmKvtATheD7QP3kMbi9aNi/GCKp1VgiRucGiNQpkvLu3
	xAkB6WmTzOCXFxKzjAS6gwsLXKtPqXr5etqIxqezF47nFEdx871pUm1Tur4bd/x8gp9nY7I
	dLF3BJnck6wj+x3t63+szCcMlRkDZcM9dWF5NPUN8DBmggkMjUdOL/j41nOLgfuY54RY8lS
	Og6or1neeKqBPHDbkoiKuUIVr5XBlmP7ZwS7CYT07xYURoEaAYhlTnOR7TeZmzlr/YiYkGC
	y7VFPDQ1NHBLBObgDRdVIJx1BELFciBwarqyh5OFl370LYuloHKDbt9ILAsFgY4fh/R9VwX
	Q1mFsqYiRPjDBoxaSrzkKT1MD9yhMwQ9Zc8JLXwpJUO6A290v3gzkXjvYuLcg==
X-QQ-GoodBg: 2
X-BIZMAIL-ID: 8892748812297823695
Date: Tue, 23 Apr 2024 08:41:01 +0800
From: Winston Wen <wentao@uniontech.com>
To: lvm-devel@lists.linux.dev
Subject: lvm2-monitor.servcie block boot process due to bad storage device
Message-ID: <BA135FC1810D838F+20240423084101.40b9659c@winn-pc>
Organization: Uniontech
X-Mailer: Claws Mail 4.2.0 (GTK 3.24.41; x86_64-pc-linux-gnu)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-QQ-SENDSIZE: 520
Feedback-ID: bizesmtpsz:uniontech.com:qybglogicsvrgz:qybglogicsvrgz6a-1

Hi,

If a device's IO does not respond, it will block in the path of
partition scanning. But at this point, it has already created the
part0, like /dev/sda, in devtmpfs, but the mutex of the device has been
held by the partition scanning code, so all processes attempting to
open it will enter a wait.

lvm scans and opens block devices under /dev/ during startup, so if
there are any bad devices mentioned above, lvm2-monitor.server will be
blocked, and because its type is oneshot, it will block the boot
process, even if the poor device is not using lvm.

May I ask if there is a way to avoid it? For example, can the
type of this service be changed from oneshot to simple? Or is there
any other better way?

Thanks!

-- 
Thanks,
Winston

