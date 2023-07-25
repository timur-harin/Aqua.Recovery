import HealthKit

class HealthKitHelper: ObservableObject {

    let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let typesToWrite: Set<HKSampleType> = []
        let typesToRead: Set<HKObjectType> = [] 

        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { success, error in
            completion(success)
        }
    }

    func saveWorkout(startTime: Date, endTime: Date, calories: Double, distance: Double) {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }

        let workoutType = HKObjectType.workoutType()
        let workout = HKWorkout(activityType: .other, start: startTime, end: endTime, workoutEvents: nil, totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: calories), totalDistance: HKQuantity(unit: .meter(), doubleValue: distance), metadata: nil)

        healthStore.save(workout) { success, error in
            if let error = error {
                print("Error saving workout: \(error.localizedDescription)")
            } else {
                print("Workout saved successfully!")
            }
        }
    }
}
