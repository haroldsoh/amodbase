/*
 * Vehicle.h
 *
 *  Created on: Mar 23, 2015
 *      Author: haroldsoh
 */

#ifndef Vehicle_H_
#define Vehicle_H_

#include "Types.hpp"
#include "Entity.hpp"

#include <unordered_set>
#include <list>
#include <boost/graph/graph_concepts.hpp>

namespace amod {

class Vehicle : public Entity {

public:
	enum Status { FREE,
	    BUSY,
	    HIRED,
	    MOVING_TO_PICKUP,
	    MOVING_TO_DROPOFF,
	    PICKING_UP,
	    DROPPING_OFF,
	    PARKED,
	    MOVING_TO_REBALANCE,
	    UNKNOWN
	};

public:
	Vehicle(int id = 0);
	Vehicle(int id, std::string name, Position pos, int capacity, Vehicle::Status status);
	virtual ~Vehicle();

	virtual Vehicle::Status getStatus() const;
	virtual void setStatus(Vehicle::Status s);

	virtual double getSpeed() const;
	virtual void setSpeed(double speed);

	virtual void setCustomerId(int cust_id);
    virtual int getCustomerId() const;
	virtual void clearCustomerId();

	virtual void setCapacity(int capacity);
	virtual int getCapacity() const;

	virtual void setWaypoints(std::list<Position> &waypoints);
	virtual void getWaypoints(std::list<Position> *waypoints);

    virtual int getLocationId(); 
    virtual void setLocationId(int loc_id);
    

private:
	Vehicle::Status status_;
	int capacity_;
	double speed_;

	int customer_id_;
	std::list<Position> waypoints_;

    int location_id_;
    
    // FOR DEBUGGING
    // TO REMOVE
public:
    int stationary_count;
};

typedef Vehicle::Status VehicleStatus;


} /* namespace AMOD */

#endif /* Vehicle_H_ */
