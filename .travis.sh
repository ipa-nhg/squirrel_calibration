set -e
set -v

while true; do echo "INSTALL IS RUNNING" && sleep 60; done&

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu trusty main" > /etc/apt/sources.list.d/ros-latest.list'
wget http://packages.ros.org/ros.key -O - | sudo apt-key add -
sudo apt-get update -qq > /dev/null 2>&1
sudo apt-get install -qq -y python-rosdep python-wstool > /dev/null 2>&1
sudo apt-get install -qq -y ros-${CI_ROS_DISTRO}-ros > /dev/null 2>&1 #needed as long as https://github.com/ros-infrastructure/rosdep/issues/430 is not fixed
sudo rosdep init
rosdep update

# create empty underlay workspace
mkdir -p $CATKIN_WS_UNDERLAY_SRC
source /opt/ros/$CI_ROS_DISTRO/setup.bash > /dev/null 2>&1 # source release
catkin_init_workspace $CATKIN_WS_UNDERLAY_SRC
cd $CATKIN_WS_UNDERLAY
catkin_make -DCMAKE_BUILD_TYPE=Release # build empty underlay devel space
catkin_make -DCMAKE_BUILD_TYPE=Release install # build empty underlay install space
# populate underlay
if [ -f $TRAVIS_BUILD_DIR/.travis.rosinstall ]; then wstool init -j10 src $TRAVIS_BUILD_DIR/.travis.rosinstall; fi
if [ ! -f $TRAVIS_BUILD_DIR/.travis.rosinstall ]; then wstool init -j10 src $DEFAULT_ROSINSTALL; fi
# install dependencies from underlay
rosdep install -q --from-paths $CATKIN_WS_UNDERLAY_SRC -i -y --rosdistro $CI_ROS_DISTRO > /dev/null #2>&1
# build devel space of underlay
source $CATKIN_WS_UNDERLAY/devel/setup.bash > /dev/null 2>&1 # source devel space of underlay
catkin_make -DCMAKE_BUILD_TYPE=Release
# build install space of underlay
catkin_make -DCMAKE_BUILD_TYPE=Release install > /dev/null #2>&1
ret=$?

# create empty overlay workspace
mkdir -p $CATKIN_WS_SRC
source $CATKIN_WS_UNDERLAY/install/setup.bash > /dev/null 2>&1 # source install space of underlay
catkin_init_workspace $CATKIN_WS_SRC
cd $CATKIN_WS
catkin_make -DCMAKE_BUILD_TYPE=Release # build empty overlay
# populate overlay
ln -s $TRAVIS_BUILD_DIR $CATKIN_WS_SRC
# install dependencies from overlay
rosdep install -q --from-paths $CATKIN_WS_SRC -i -y --rosdistro $CI_ROS_DISTRO > /dev/null #2>&1
# build overlay
source $CATKIN_WS/devel/setup.bash > /dev/null 2>&1 # source devel space of overlay
catkin_make -DCMAKE_BUILD_TYPE=Release
catkin_make -DCMAKE_BUILD_TYPE=Release install > /dev/null
# source $CATKIN_WS/install/setup.bash > /dev/null 2>&1 # source install space of overlay for testing TODO: the current catkin implementation does not allow to test in install space
if [ "$CATKIN_ENABLE_TESTING" == "OFF" ]; then
  echo "Testing disabled"
else
  mkdir -p $CATKIN_WS/build/test_results # create test_results directory to prevent concurrent tests to fail create it
  catkin_make run_tests $CATKIN_TEST_ARGUMENTS # test overlay
fi
catkin_test_results --verbose
ret=$?

kill %%
exit $ret