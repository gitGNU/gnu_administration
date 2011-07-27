""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Savannah vim functions used for moderations.
" Copyright (c) 2002, 2003, 2004 Mathieu Roy <yeupou@gnu.org>
"                                Jaime Villate <villate@gnu.org>
"                                Rudy Gevaert <rudy@gnu.org>
"
" Copyright (c) 2004 Elfyn McBratney <beu@gnu.org>
" Copyright (c) 2004, 2005  Sylvain Beucler <beuc@gnu.org>
" Copyright (c) 2007  Jean-Michel Frouin <jmfrouin@gnu.org>
"
" http://savannah.gnu.org & http://savannah.nongnu.org
"
"   This program is free software; you can redistribute it and/or
"   modify it under the terms of the GNU General Public License
"   as published by the Free Software Foundation; either version 2
"   of the License, or (at your option) any later version.
"
"   This program is distributed in the hope that it will be useful,
"   but WITHOUT ANY WARRANTY; without even the implied warranty of
"   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"   GNU General Public License for more details.
"
"   You should have received a copy of the GNU General Public License
"   along with this program; if not, write to the Free Software
"   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
"   02110-1301 USA.
"
"
" INSTALLATION: 
" Put this file in ~/.vim/plugin for auto-load .
" or
" :source savannah.vim to load it.
"
" USAGE:
" Insert sv_opening:
" :call Opening()
" 
" AUTHORS:
"
"   Loic Dachary, Jaime Villate and Mathieu Roy.  There are some
"   quotes from http://www.gnu.org/licenses/.  Rudy Gevaert imported
"   the changes that Paul A. Crable suggested and added the sections
"   about the LGPL.  Elfyn McBratney re-worked sv-closing into
"   sv-closing-reply and sv-closing-resubmit, and added
"   sv-deleted-pending and sv-problem-fdl-info. Sylvain Beucler made
"   lots of changes tracked via CVS, with suggestions or patches from
"   Jonathan V. Gonzales and Sebastian Wieseler. Jean-Michel Frouin port
"   it to vim, renamed sv-approve-without-source-code 
"   in sv-suggest-hosting-without-source-code and add comments on
"   SV_problem_copyright_holder
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" For debug:
" echomsg 'savannah admin help script'


" Used at the opening of the evaluation
fu! SV_opening()
		execute "normal IHi,I'm evaluating the project you submitted for approval in Savannah."
		echo "Inserted sv-opening text."
endfu

" Used at the opening of the evaluation - verbose version
fu! SV_opening_verbose()
		execute "normal IHi,I'm evaluating the project you submitted for approval in Savannah. While doing so I have noticed a few problems which are described below."
		echo "Inserted sv-opening-verbose text."
endfu

" Ask the user to resubmit their project with the requested changes made
fu! SV_closing_resubmit()
		execute "normal IPlease register your project once more with the changes mentioned above.Make sure to apply all changes requested, so you will only need to re-register once.The re-registration URL found in our acknowledgment of your earlier registration will direct you to the proper location where you can re-register your project.Regards."
		echo "Inserted sv-closing-resubmit text."
endfu 

" Ask the user to resubmit their project in English
fu! SV_closing_english_resubmit()
		execute "normal IPlease resubmit your project in English. English is the only language that the whole Savannah team understands and is needed for transparency and archival purposes.Regards."
		echo "Inserted sv-closing-english-resubmit text."
endfu

" Ask the user to reply with an updated tarball.
fu!  SV_closing_reply()
		execute "normal IIf you are willing to make the changes mentioned above, please provide us with an URL to an updated tarball of your project.  Upon review, we will reconsider your project for inclusion in Savannah.To help us better keep track of your registration, please use the tracker's web interface following the link below. Do not reply directly, the registration process is not driven by e-mail, and we will not receive such replies.Regards."
		echo "Inserted sv-closing-reply text."
endfu

fu! SV_closing_eval()
		execute "normal ISince you do not request a Savannah project, but a GNU Evaluation, please tell gnueval-input@gnu.org that you would like your project to be evaluated. They will reply with a form to fill in, where you will have to describe your project in detail and answer a few questions.You might want to keep a bookmark to this tracker item (it remains accessible even after it is closed); you are likely to copy/paste some of your answers from it to the GNU Evaluation form.Regards."
		echo "Inserted sv-closing-eval text."
endfu

" Inform the user that their submission looks void
fu! SV_closing_void()
		execute "normal IHiAs this submission looks void I'm closing it. If this isn't the case, please re-submit your project for evaluation, but make sure to read the Savannah hosting requirements before. These can be found at https://savannah.gnu.org/register/requirements.php.Regards."
		echo "Inserted sv-closing-void text."
endfu

" Inform the user of the status of their pending project due to lack of response
fu! SV_ping()
		execute "normal IHi,I am waiting for an answer from you.If within one week I still do not get a reply, I will remove your project. You will still be able to register it again once you have the time to deal with the registration issues.Are you still willing to host your project at Savannah? If not, please tell us - we don't bite, and it will make us gain time.Regards."
		echo "Inserted sv-ping text."
endfu 

fu! SV_deleted_pending()
		call SV_timeout()
endfu

fu! SV_timeout()
		execute "normal IHi,We did not get a response from you, so we deleted your project from the pending queue.If you would still like to have your project hosted at Savannah, please register it again.The re-registration URL found in our acknowledgment of your earlier registration will direct you to the proper location where you can re-register your project.Regards."
		echo "Inserted sv-timeout text."
endfu

" Registration problems

" Ask the user for a more detailed project description
fu! SV_problem_details()
		execute "normal IWe need a detailed technical description that specifies such requirements as programming languages and external libraries.  It should be at least one-half a page."
		echo "Inserted sv-problem-details text."
endfu

" Ask the user for an URL to the source code
fu! SV_problem_tarball()
		execute "normal IPlease include a (perhaps temporary) URL pointing to the source code. Alternatively, you can forward the code to me by email or attach it to this tracker.We wish to review your source code, even if it is not functional, to catch potential legal issues early.For example, to release your program properly under the GNU GPL you must include a copyright notice and permission-to-copy statements at the beginning of every  copyrightable file, usually any file more than 10 lines long.  This is explained in http://www.gnu.org/licenses/gpl-howto.html. Our review would help catch potential omissions such as these.Note that sending code to our repositories _is_ a release, since the code will then be publicly available through anonymous access."
		echo "Inserted sv-problem-tarball text."
endfu

" Ask the user to add copyright statements and GPL permission to copy statements to every source file and add a verbatim plain-text copy of the GPL license
fu! SV_problem_gpl_info()
		execute "normal IIn order to release your project properly and unambiguously under the GNU GPL, please place copyright notices and permission-to-copy statements at the beginning of every copyrightable file, usually any file more than 10 lines long.In addition, if you haven't already, please include a copy of the plain text version of the GPL, available from http://www.gnu.org/licenses/gpl.txt, into a file named \"COPYING\".For more information, see http://www.gnu.org/licenses/gpl-howto.html.If some of your files cannot carry such notices (e.g. binary files), then you can add a README file in the same directory containing the copyright and license notices. Check http://www.gnu.org/prep/maintain/html_node/Copyright-Notices.html for further information.The GPL FAQ explains why these procedures must be followed.  To learn why a copy of the GPL must be included with every copy of the code, for example, see http://www.gnu.org/licenses/gpl-faq.html#WhyMustIInclude."
		echo "Inserted sv-problem-gpl-info text."
endfu

" Ask the user to add copyright statements and LGPL permission to copy statements to every source file and add a verbatim plain-text copy of the LGPL license
fu! SV_problem_lgpl_info()
		execute "normal IIn order to release your project properly and unambiguously under the LGPL, please place copyright notices and permission-to-copy statements at the beginning of every copyrightable file, usually any file more than 10 lines long.In addition, if you haven't already, please include a copy of the plain text version of the GNU LGPL, available from http://www.gnu.org/licenses/lgpl.txt, into a file named \"COPYING\".If some of your files cannot carry such notices (e.g. binary files), then you can add a README file in the same directory containing the copyright and license notices. Check http://www.gnu.org/prep/maintain/html_node/Copyright-Notices.html for further information.For more information, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.html#SEC4 ."
		echo "Inserted sv-problem-lgpl-info text."
endfu

" Ask the user to add copyright statements and FDL permission to copy statements after the title page of the collective work and add a verbatim plain-text copy of the  FDL license
fu! SV_problem_fdl_info()
		execute "normal IIn order to release your project properly and unambiguously under the GFDL, please place copyright notices and permission-to-copy statements after the title page of each work.In addition, if you haven't already, please add a copy of the FDL (available from http://www.gnu.org/licenses/fdl.html in various formats) as a section of your works.For more information, see http://www.gnu.org/licenses/fdl.html#addendumhttp://www.gnu.org/licenses/fdl-howto.html also covers additional points, including a smaller notice that you can use in auxiliary files."
		echo "Inserted sv-problem-fdl-info text."
endfu

fu! SV_problem_copyright_notices()
		execute "normal IYou added the license notices, but did not add appropriate copyright notices.Please check http://www.gnu.org/prep/maintain/html_node/Copyright-Notices.html for more information, and update your files."
		echo "Inserted sv-problem-copyright-notices text."
endfu


" This problem apply when a copyright older is not a legal entity, for example : (C) Pseudo or (C) scleaner project.
" Submitter have to change it for a real legal entity like : (C) Jean-Michel Frouin, (C) FSF or (C) My Firm
fu! SV_problem_copyright_holder()
		execute "normal IIs the copyright holder referred to in the copyright notices, a legal entity that can be assigned copyright? If not, you need to add the author(s)' name(s) instead.Check http://www.gnu.org/prep/maintain/html_node/Copyright-Notices.html for more information, and update your files."
		echo "Inserted sv-problem-copyright-holder text."
endfu

" Ask the user to update the FSF address (noted in their sources)
fu! SV_problem_fsf_address()
		execute "normal IThe address of the FSF has changed, and is now:51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USAPlease update your license notices.Please update the copy of the license (usually, the 'COPYING' file) in your package as well.Updated versions of the GPL, LGPL and GFDL can also be found at:http://www.gnu.org/licenses/gpl.txthttp://www.gnu.org/licenses/lgpl.txthttp://www.gnu.org/licenses/fdl.txtYou can find some background and a possible migration script at https://savannah.gnu.org/forum/forum.php?forum_id=3766(alternatively the GNU (L)GPLv3 standard notices include different wording that do not mention the FSF snail mail address - see http://www.gnu.org/licenses/gpl.html#howto)"
		echo "Inserted sv-problem-fsf-address text."
endfu

" Ask the user to use a complete verbatim copy of the license
fu! SV_problem_license_truncated()
		execute "normal IThe license does not contain the last section, titled \"How to Apply These Terms to Your New Programs\".Please use a complete verbatim copy of the license, which may be found at http://www.gnu.org/licenses/gpl.txt, http://www.gnu.org/licenses/lgpl.txt or http://www.gnu.org/licenses/fdl.txt.The license must be copied verbatim and in its entirety."
		echo "Inserted sv-problem-license-truncated text."
endfu

" Ask the user to make sure that their project works with free java
fu! SV_problem_java()
		execute "normal IYou must determine whether your project can run on a Free Software Java suite \(see https://savannah.gnu.org/maintenance/JavaIssues and http://www.gnu.org/software/java/ for more information\).We recommend you to test your project using IcedTea, or GCJ + GNU Classpath, and ensure that your Java code runs on this Free Software Java suite.IceTea is based on Sun's OpenJDK and uses free replacements for its proprietary parts. GCJ is the GNU Compiler for Java, part of the GCC (GNU Compiler Collection).  The Classpath project aims to develop a free and portable implementation of the Java API \(the classes in the 'java' package\).More information is available at http://icedtea.classpath.org/ , http://gcc.gnu.org/ and http://www.gnu.org/software/classpath/ .Please provide us with more information about this point."
		echo "Inserted sv-problem-java text."
endfu

" Ask the user to make sure that their project works with free .NET
fu! SV_problem_dotnet()
		execute "normal IYou must determine whether your project can run on a Free Software .NET suite.We recommend you to test your project against DotGNU Portable .NET and Mono, and ensure that your code runs on this Free Software .NET suite (see www.dotgnu.org and www.mono-project.com for more information).Please provide us with more information about this point."
		echo "Inserted sv_problem-dotnet text"
endfu

" Ask user to remove GNU from the name of the project
fu! SV_problem_uses_gnu_name()
		execute "normal IYour project is not yet part of the GNU project, so we cannot accept its current name.While there are non-GNU programs with names that include 'gnu', such as gnuplot and gnuboy, they are not hosted on Savannah.\n We want to maintain the distinction between GNU and non-GNU projects.When your project is accepted into the GNU project you may change its name. You can do this by asking us."
		echo "Inserted sv-problem-uses-gnu-name text."
endfu

" Tell the user that if approved, their project will be non-GNU
fu! SV_problem_uses_gnu_type()
		execute "normal IYour project is not part of the GNU project, so we cannot accept its current type.  We want to maintain the distinction between 'GNU' and'non-GNU' projects.  If your project is approved for inclusion into Savannah, we will set it's type to 'non-GNU'.If your project is accepted into the GNU project you may change its type.  You can do this by asking us."
		echo "Inserted sv-problem-uses-gnu-type text."
endfu

" Tell the user that the license they have chosen is GPL-incompatible
fu! SV_problem_license_gplincompatible()
		execute "normal IThe license you chose qualifies your software as free software but it is incompatible with the GNU GPL.We only host software published under licenses compatible with the GPL, which allows developers to combine files from any project without fear of a licensing problem.If you are willing to switch to a GPL-compatible license, please resubmit the project.You can get a list of various licenses and comments about them at http://www.gnu.org/philosophy/license-list.html.If you still wish to use your current license, we will be happy to discuss it with you."
		echo "Inserted sv-problem-license-gplincompatible text."
endfu

" Project uses MPL-like GPL-incompatible license
fu! SV_problem_license_mpl_alike()
		execute "normal IThe license you chose qualifies your project as free software but it is incompatible with the GNU GPL because it is similar to the MPL.MPL 1.0 is incompatible with the GNU GPL.  That is, combining a module covered by the GPL with a module covered by the MPL is not legal. MPL 1.1, however, allows \(section 13\) a program \(or parts of it\) to offer a choice of another license as well.  Any part of a program that allows the GNU GPL, or many of its variants, as an alternate choice, is considered to have a GPL-compatible license.We only host software published under licenses compatible with the GPL, which allows developers to combine files from any project without fear of a licensing problem.If you're willing to switch to a GPL-compatible license, or dual license with a GPL-compatible license and a MPL 1.1 license, please resubmit.You can read a discussion of various licenses at http://www.gnu.org/philosophy/license-list.html for more information."
		echo "Inserted sv-problem-license-mpl-alike text."
endfu

" Ask user to change "Open" to "Free" in their project name
fu! SV_problem_open_in_name()
		execute "normal ISavannah's mission is to host free software projects, and we want the public to think of them as free software projects.  A project name that says \"open\" will tend to lead people to think of the project as \"open source\" instead of \"free software\".We would be glad if you accept to use \"free\" instead of \"open\" in your project name."
		echo "Inserted sv-problem-open-in-name text."
endfu

" Ask the user to consider using GPL v2 (or later)
fu! SV_problem_gpl_two_only()
		execute "normal ILicensing under the \"GNU GPL v2 only\" is problematic.  Would you agree to license your project under the \"GNU GPL v2 or later\"?The reason for this is that when we publish the next version of the GPL, it will be important for all GPL-covered programs to advance to that new version. If you don't put this in the files now, the only way to port your program to the next version of the GPL would be to ask each and every copyright holder, and that may be very difficult.We can explain the issue in more detail if you wish. If you have concerns about \"GNU GPL v2 or later\", we'd be happy to address them too."
		echo "Inserted sv-problem-gpl-two-only text."
endfu

" Ask the user how he plans to use Savannah in the context of a distro project.
fu! SV_problem_distro()
		execute "normal IAs mentioned in the registration pages, we do not host complete distros, distros isos, packages repositories, etc, mainly because we couldn't check the licenses of each and every package it is composed of. We may just offer support for organisational purpose and dedicated software (such as iso creation scripts).How do you plan to use the Savannah services?If you plan to host such software:"
		call SV_problem_tarball()
		echo "Inserted sv-problem-distro text."
endfu

" Ask the user to use SV and not SF for primary development
fu! SV_problem_sfnet()
		execute "normal ISavannah is a central point for development, distribution and maintenance of GNU Software.There is a companion site savannah.nongnu.org where we also host Free Software projects that are not part of the GNU Project, but run on free platforms.However, we do not allow to host your project on Savannah and SourceForge at the same time, if Savannah is just a project mirror. Your project development should happen primarily on Savannah.How do you plan to use your Savannah account?"
		echo "Inserted sv-problem-sfnet text."
endfu

" Project rejection

" Reject project that depends on a non-free operating system
fu! SV_reject_nonfree_operating_system()
		execute "normal IEven though your project is Free Software it can not be hosted here.We only host projects that can run on a free operating system \(such as GNU/Linux\).We have adopted this policy because now that completely free operating systems exist, we do not want to encourage users of those systems to start using proprietary operating systems so that they can use your program.If you are willing to maintain a version for free operating systems, which work as well as or better than other ports, you can then provide versions for non-free systems as well. The idea is that at no point should only-free users be at a disadvantage compared to users of proprietary software.Your project should always work equally well in free systems as in any other version you provide; if you have some modules for non-free systems, you can delay their release until you have released the free operating system version.If you accept this commitment then please state so and the project should be approved in Savannah.Thank you for your understanding.Regards."
		echo "Inserted sv-reject-nonfree-operating-system text."
endfu

" Reject project that depends on proprietary software
fu! SV_reject_proprietary()
		execute "normal IYour project requires proprietary software and cannot be hosted on Savannah for this reason.Savannah is willing to provide resources and time to developers writing Free Software that can be used without the need to ask permission from proprietary software vendor.If, someday, you get free of those dependencies, feel free to resubmit your project.Thank you for your understanding.Regards."
		echo "Inserted sv-reject-proprietary text."
endfu

" Reject project that depends on non-free java
fu! SV_reject_java_nonfree()
		execute "normal IYour project requires proprietary software and cannot be hosted on Savannah for this reason.Savannah is willing to provide resources and time to developers writing Free Software that can be used without the need to ask permission from a proprietary software vendor.If, someday, you get free of those dependencies (see http://www.gnu.org/software/java for more information), do not hesitate to resubmit your project.Thank you for your understanding.Regards."
		echo "Inserted sv-reject-java-nonfree text."
endfu

" Reject cracking software
fu! SV_reject_cracking()
		execute "normal IYou described your project as a piece of software primarily aimed at cracking purposes. We do not want to encourage such practice, and hence cannot approve your project.However, if you think this project can be modified to primarily serve system administrators aims instead of the crackers', and if you want to keep the development in that direction, we may reconsider your project. Please then resubmit your project with a description fitting this goal.Regards."
		echo "Inserted sv-reject-cracking text."
endfu

" Project approval

" Approve project
fu! SV_approve()
		execute "normal IHi,I have approved your project.  You will receive an automated e-mail containing detailed information about the approval.Regards."
		echo "Inserted sv-approve text."
endfu

" Problem without source code (and will be checked later)
" Once the user acknowledges, use sv-approve().
fu! SV_suggest_hosting_without_source_code()
		execute "normal IHi,Your projects meets the Savannah requirements, except that we cannot review your source code yet.We prefer to approve project with source code, so we can check it for legal issues (even non-functional code is OK). We will among others check if the source files contain appropriate copyright notice and permission-to-copy statements at the beginning of every copyrightable file. Our review helps catch potential legal issues early.If you need Savannah right now, please explain to us why; otherwise, please resubmit the project when you have source code.If we approve your project without source code, we will review the code in the near future (or better, at your request). If then the source code does not meet our requirements (for example, non-free dependencies), we will then discuss the issue and possibly remove the project from Savannah.Do you need the Savannah services now, and if yes do you agree with the above conditions?Regards."
		echo "Inserted sv-problem-without-source-code text."
endfu

" Set the project type as non-GNU
fu! SV_set_as_nongnu()
		execute "normal ISince your project is not GNU yet (at least I cannot find it on our official list), I set your project type as non-GNU. If you would like to offer your project to the GNU project, please:- fix the issues we mentioned, as the Savannah policies also apply for GNU projects- then contact the GNU Eval team, following the instructions at http://www.gnu.org/help/evaluation.html ."
		echo "Inserted sv-approve-as-nongnu text."
endfu

" Approve as non-GNU
fu! SV_approve_as_nongnu()
		execute "normal IHi,I have approved your project as non-GNU. You will receive an automated e-mail containing detailed information about the approval. If you would like to offer your project to the GNU project, please contact the GNU Eval team, following the instructions at http://www.gnu.org/help/evaluation.html .Regards."
		echo "Inserted sv-approve-as-nongnu text."
endfu

" Confusing statements
" The user confuses commercial with proprietary
fu! SV_confusion_commercial_and_proprietary()
		execute "normal INote that commercial does not mean proprietary.Free Software means that users have certain freedoms; it does not mean zero price.  \"Commercial\" means \"associated with business\"; a commercial program may be free or non-free, depending on its license.  So it is a mistake to treat \"free\" and \"commercial\" as contraries.  When a business develops free software, that is free commercial software."
		echo "Inserted sv-confusion-commercial-and-proprietary text."
endfu

" The user confuses open with free
fu! SV_confusion_open_and_free()
		execute "normal INote that Savannah supports projects of the Free Software movement, not projects of the Open Source movement.We are careful about ethical issues and insist on producing software that is not dependent on proprietary software.While Open Source as defined by its founders means something pretty close to Free Software, it's frequently misunderstood.  For more information, please see http://www.gnu.org/philosophy/free-software-for-freedom.html."
		echo "Inserted sv-confusion-open-and-free text."
endfu

" Ask the user to change "Linux" to "GNU/Linux"
fu! SV_confusion_linux_vs_gnu()
		execute "normal I\"Linux\" is just a kernel of a more complex system that we like to refer to as GNU/Linux, to emphasize the ideals of the Free Software movement.Would you mind changing references to Linux as an OS to GNU/Linux?For more information, see http://www.gnu.org/gnu/linux-and-gnu.html."
		echo "Inserted sv-confusion-linux-vs-gnu text."
endfu

" Points the user to GNU Eval if (s)he doesn't need a Savannah account.
fu! SV_confusion_eval()
		execute "normal IPlease note that this is not the GNU Evaluation. This is the Savannah evaluation, to check whether your project complies with the Savannah hosting rules (a subset of the GNU Evaluation policies), and get a place to host your project. If you are approved at Savannah and want to be part of GNU, then we usually approve your project as non-GNU and forward your submission to the GNU Eval team.If you do not want to host your project here, but want to have your project evaluated by the GNU Eval team, then you only need to write to gnueval-input@gnu.org.Can you clarify this point?"
		echo "Inserted sv-confusion-eval text."
endfu

" Is the project active (p = predicat :))
fu! SV_active_p()
		execute "normal IHi,As promised I review your project again.I see the project is currently empty. Can you give me the status of this project? Do you still work on it?"
		echo "Inserted sv-active-p text."
endfu

fu! SV_ping_without_source_code()
		execute "normal IHello,When we approved your project, we made it clear that we would review it in the near future, to check its compliance with our policies.Please reply asap to this tracker. If within one week we still do not get a reply, we will close the account.Regards."
		echo "Inserted sv-active-p text."
endfu

fu! SV_problem_usage()
		execute "normal ISavannah is meant to help developers organize a team and produce code. This mean we provide resources to projects so they can actually manage their project, and we do not host a download area only.I mention this because I saw you already have (among others) a ***FIX_ME*** account. Can you tell me how you plan to use Savannah?"
		echo "Inserted sv-problem-usage text."
endfu
