#
# This file is open source software, licensed to you under the terms
# of the Apache License, Version 2.0 (the "License").  See the NOTICE file
# distributed with this work for additional information regarding copyright
# ownership.  You may not use this file except in compliance with the License.
#
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

#
# Copyright (C) 2022 ScyllaDB
#

find_package (PkgConfig REQUIRED)

pkg_search_module (LibUring IMPORTED_TARGET GLOBAL liburing)

if (LibUring_FOUND)
  add_library (URING::uring INTERFACE IMPORTED)
  target_link_libraries (URING::uring INTERFACE PkgConfig::LibUring)
  set (URING_LIBRARY ${LibUring_LIBRARIES})
  set (URING_INCLUDE_DIR ${LibUring_INCLUDE_DIRS})
endif ()

if (NOT URING_LIBRARY)
  find_library (URING_LIBRARY
    NAMES uring)
endif ()

if (NOT URING_INCLUDE_DIR)
  find_path (URING_INCLUDE_DIR
    NAMES liburing.h)
endif ()

if (URING_INCLUDE_DIR)
  include (CheckStructHasMember)
  include (CMakePushCheckState)
  cmake_push_check_state (RESET)
  list(APPEND CMAKE_REQUIRED_INCLUDES ${URING_INCLUDE_DIR})
  CHECK_STRUCT_HAS_MEMBER ("struct io_uring" features liburing.h
    HAVE_IOURING_FEATURES LANGUAGE CXX)
  cmake_pop_check_state ()
endif ()

mark_as_advanced (
  URING_LIBRARY
  URING_INCLUDE_DIR
  HAVE_IOURING_FEATURES)

include (FindPackageHandleStandardArgs)

find_package_handle_standard_args (LibUring
  REQUIRED_VARS
    URING_LIBRARY
    URING_INCLUDE_DIR
    HAVE_IOURING_FEATURES
  VERSION_VAR LibUring_VERSION)

if (LibUring_FOUND)
  set (URING_LIBRARIES ${URING_LIBRARY})
  set (URING_INCLUDE_DIRS ${URING_INCLUDE_DIR})
  if (NOT (TARGET URING::uring))
    add_library (URING::uring UNKNOWN IMPORTED)

    set_target_properties (URING::uring
      PROPERTIES
        IMPORTED_LOCATION ${URING_LIBRARY}
        INTERFACE_INCLUDE_DIRECTORIES ${URING_INCLUDE_DIRS})
  endif ()
endif ()
