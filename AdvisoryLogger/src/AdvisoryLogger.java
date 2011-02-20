import java.util.HashMap;
import java.util.Map;

import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Session;

import org.apache.activemq.ActiveMQConnection;
import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.ActiveMQMessageConsumer;
import org.apache.activemq.ActiveMQSession;
import org.apache.activemq.command.ActiveMQMessage;
import org.apache.activemq.command.ConsumerInfo;
import org.apache.activemq.command.DataStructure;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class AdvisoryLogger implements Runnable{

	private static final long RUN_DURATION = 10000; // milliseconds

	private final ActiveMQConnectionFactory factory;
	Map<Destination, Integer> counts = new HashMap<Destination, Integer>();

	Log log = LogFactory.getLog(this.getClass());

	public AdvisoryLogger(String conn) {
		factory = new ActiveMQConnectionFactory(conn);
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		String conn = args[0];
		AdvisoryLogger al = new AdvisoryLogger(conn);
		al.run();
	}

	@Override
	public void run() {
		try {
			log.info("This test will run for " + RUN_DURATION + " milliseconds and the write out summary statistics on MessageConsumers for each queue,");
			ActiveMQConnection conn = (ActiveMQConnection) factory.createConnection();
			long now = System.currentTimeMillis();
			conn.start();
			ActiveMQSession s = (ActiveMQSession) conn.createSession(false, Session.AUTO_ACKNOWLEDGE);
			Destination destination = s.createTopic("ActiveMQ.Advisory.Consumer.Queue.>");
			ActiveMQMessageConsumer mc = (ActiveMQMessageConsumer) s.createConsumer(destination );
			while(System.currentTimeMillis() - now < RUN_DURATION){
				ActiveMQMessage m = (ActiveMQMessage) mc.receive(50);
				if(m!= null)
				{
					DataStructure x = m.getDataStructure();
					if (x instanceof ConsumerInfo) {
						ConsumerInfo ci = (ConsumerInfo) x;
						Destination d = ci.getDestination();
						if(!counts.containsKey(d))
						{
							counts.put(d, 1);
						} else {
							counts.put(d, counts.get(d) + 1);
						}
					}
				}
			}
			log.info("stopping");
			conn.stop();
			for(Map.Entry<Destination, Integer> e : counts.entrySet())
			{
				log.info(e.getKey() + " " + e.getValue() + " at a rate of " + e.getValue() * 1.0 / RUN_DURATION * 1000 + " per second");
			}
			System.exit(0);
		} catch (JMSException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
