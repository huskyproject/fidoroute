%global ver_major 1
%global ver_minor 38

# release number for Release: header
%global relnum 1

%global debug_package %nil

# for generic build; will override for some distributions
%global vendor_prefix %nil
%global vendor_suffix %nil
%global pkg_group Applications/Communications

# for CentOS, Fedora and RHEL
%if %_vendor == "redhat"
    %global vendor_suffix %dist
%endif

# for ALT Linux
%if %_vendor == "alt"
    %global vendor_prefix %_vendor
    %global pkg_group Networking/FTN
%endif

Name: fidoroute
Version: %ver_major.%ver_minor
Release: %{vendor_prefix}%relnum%{vendor_suffix}
%if %_vendor != "redhat"
Group: %pkg_group
%endif
Summary: fidoroute is a Fidonet node route file generator
URL: https://github.com/huskyproject/%name/archive/v%ver_major.%ver_minor.tar.gz
License: GPLv2
Source: %name-%ver_major.%ver_minor.tar.gz
BuildRequires: gcc-c++

%description
fidoroute is a Fidonet node route file generator

%prep
%setup -q -n %name-%ver_major.%ver_minor

%build
%make_build

%install
umask 022
%make_install PREFIX=/usr
chmod -R a+rX,u+w,go-w %buildroot

%files
%defattr(-,root,root)
%_bindir/fidoroute
%_mandir/man1/fidoroute.*
%_mandir/man5/fidoroute.conf.*
