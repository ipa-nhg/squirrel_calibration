/*!
 *****************************************************************
 * \file
 *
 * \note
 * Copyright (c) 2015 \n
 * Fraunhofer Institute for Manufacturing Engineering
 * and Automation (IPA) \n\n
 *
 *****************************************************************
 *
* \note
* Repository name: squirrel_calibration
* \note
* ROS package name: relative_localization
 *
 * \author
 * Author: Richard Bormann
 * \author
 * Supervised by:
 *
 * \date Date of creation: 10.08.2016
 *
 * \brief
 *
 *
 *****************************************************************
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer. \n
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution. \n
 * - Neither the name of the Fraunhofer Institute for Manufacturing
 * Engineering and Automation (IPA) nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission. \n
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License LGPL as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License LGPL for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License LGPL along with this program.
 * If not, see <http://www.gnu.org/licenses/>.
 *
 ****************************************************************/

#ifndef CORNER_LOCALISATION_H
#define CORNER_LOCALISATION_H

#include <iostream>
#include <vector>

// ROS
#include "ros/ros.h"

// messages
#include "sensor_msgs/LaserScan.h"
#include "visualization_msgs/Marker.h"

// tf
#include <tf/tf.h>
#include <tf/transform_broadcaster.h>

// dynamic reconfigure
#include <dynamic_reconfigure/server.h>
#include <relative_localization/CheckerboardLocalisationConfig.h>

// OpenCV
#include <opencv/cv.h>


class CornerLocalization
{
public:
	CornerLocalization(ros::NodeHandle& nh);
	~CornerLocalization() {};


private:

	void callback(const sensor_msgs::LaserScan::ConstPtr& laser_scan_msg);
	void dynamicReconfigureCallback(robotino_calibration::CheckerboardLocalisationConfig& config, uint32_t level);

	ros::NodeHandle node_handle_;
	ros::Subscriber laser_scan_sub_;
	ros::Publisher marker_pub_;

	tf::TransformBroadcaster transform_broadcaster_;

	dynamic_reconfigure::Server<robotino_calibration::CheckerboardLocalisationConfig> dynamic_reconfigure_server_;
	tf::Vector3 avg_translation_;
	tf::Quaternion avg_orientation_;
	double update_rate_;
	std::string child_frame_name_;

	// parameters
	double wall_length_left_;		// the length of the wall segment left of the checkerboard's origin, in[m]
	double wall_length_right_;		// the length of the wall segment right of the checkerboard's origin, in[m]
	double max_wall_side_distance_;		// the maximum distance of the side wall to the laser scanner, in[m]
};

#endif // CORNER_LOCALISATION_H